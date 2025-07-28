<script>
  import { run } from 'svelte/legacy';

  import { onMount } from "svelte";

  import { geoMercator, geoPath } from "d3-geo";

  import tippy, { followCursor } from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import "tippy.js/themes/light.css";

  import { extent } from "d3-array";

  import geoJson from "../data/missouri-counties.json";

  /**
   * @typedef {Object} Props
   * @property {any} data
   * @property {number} [width]
   * @property {any} colorScales
   * @property {string} [selectedVariable]
   * @property {any} [propertyMap]
   */

  /** @type {Props} */
  let {
    data,
    width = 800,
    colorScales,
    selectedVariable = "pesticides",
    propertyMap = {}
  } = $props();

  let height = $derived(width * 0.6);

  let paths = $state([]);

  let tippyInstances = $state([]);

  let projection = $derived(geoMercator().fitSize([width, height], geoJson));

  let pathGenerator = $derived(geoPath().projection(projection));

  let updatePaths = $derived((fillVariable) => {
    // Merge data into GeoJSON features
    const mergedData = geoJson.features.map((feature) => {
      const featureData = data.find(
        (d) =>
          d.fips.toString() ===
          feature.properties.STATE + feature.properties.COUNTY,
      );
      feature.properties.pesticides = featureData
        ? featureData[propertyMap.pesticides]
        : null;
      feature.properties.cancer = featureData
        ? featureData[propertyMap.cancer]
        : null;
      feature.properties.value = featureData
        ? featureData[propertyMap[fillVariable]]
        : null;
        feature.properties.top4_chems = featureData
        ? featureData.top4_chems
        : null;
      return feature;
    });

    // Define color domain
    const values = mergedData
      .map((d) => d.properties.value)
      .filter((v) => v !== null);

    const [min, max] = extent(values);

    colorScales[fillVariable].domain([min, max]);

    // Create paths with fill color
    paths = mergedData.map((d) => ({
      d: pathGenerator(d),
      feature: d.properties.NAME,
      pesticides: d.properties.pesticides, 
      cancer: d.properties.cancer,
      top4_chems: d.properties.top4_chems,
      fill:
        d.properties.value !== null
          ? colorScales[fillVariable](d.properties.value)
          : "#ddd",
    }));

  });

  run(() => {
    updatePaths(selectedVariable);
  });

  function initializeTooltips() {
    // Destroy existing instances first
    if (tippyInstances.length > 0) {
      tippyInstances.forEach(instance => {
        instance.destroy();
      });
    }

       // Create new tooltip instances
       tippyInstances = tippy("[data-tippy-content]", {
      theme: "light",
      duration: 0,
      followCursor: true,
      plugins: [followCursor],
      allowHTML: true,
    });
  }

  onMount(() => {
    initializeTooltips();
  });

    // Reinitialize tooltips when selectedVariable changes
    $effect(() => {
    selectedVariable; // Subscribe to changes
    if (paths.length > 0) {
      // Small delay to ensure DOM is updated
      setTimeout(initializeTooltips, 50);
    }
  });


//Helper function to get tooltip content based on selected variable 
function getTooltipContent(feature, pesticides, cancer, selectedVar, top4_chems) {
    const countyName = `<b style="font-size: 1.2em;">${feature} County</b><br/>`;
    
    if (selectedVar === 'pesticides') {
      return countyName + (pesticides !== null 
        ? `Pesticides per sq mile: <b>${pesticides} kg</b> <br/> <br/>
        Most prevalent chemicals:
        <div>
          ${top4_chems?.split(",").map(d=>`<div>${d}</div>`).join("")}
          </div>
        `
        : "No pesticide data available");
    } else if (selectedVar === 'cancer') {
      return countyName + (cancer !== null 
        ? `Cancer Rate per 100K: <b>${cancer}</b>`
        : "No cancer data available");
    }
  }
</script>

<svg {width} {height}>
  {#key selectedVariable}
    {#each paths as { d, fill }}
      <path {d} {fill} stroke="#333" stroke-width="0.5"></path>
    {/each}
  {/key}

  <g>
    {#each paths as { d, feature, pesticides, cancer, top4_chems }}
      <path
        {d}
        fill="transparent"
        stroke="#000"
        stroke-width="1"
        data-tippy-content={getTooltipContent(feature, pesticides, cancer, selectedVariable, top4_chems)}
        class="outline"
      ></path>
    {/each}
  </g>
</svg>

<style lang="scss">
  svg {
    margin-top: 10px;

    path.outline {
      opacity: 0;
      &:hover {
        stroke: #000;
        stroke-width: 2px;
        opacity: 1;
      }
    }
  }
</style>
