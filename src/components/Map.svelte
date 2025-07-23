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
      fill:
        d.properties.value !== null
          ? colorScales[fillVariable](d.properties.value)
          : "ddd",
    }));
  });

  run(() => {
    updatePaths(selectedVariable);
  });

  onMount(() => {
    tippy("[data-tippy-content]", {
      theme: "light",
      duration: 0,
      followCursor: true,
      plugins: [followCursor],
      allowHTML: true,
    });
  });
</script>

<svg {width} {height}>
  {#key selectedVariable}
    {#each paths as { d, fill }}
      <path {d} {fill} stroke="#333" stroke-width="0.5"></path>
    {/each}
  {/key}

  <g>
    {#each paths as { d, feature, pesticides, cancer }}
      <path
        {d}
        fill="transparent"
        stroke="#000"
        stroke-width="1"
        data-tippy-content={`
          <b style="font-size: 1.2em;">${feature} County</b><br/>
          ${
            feature && pesticides
              ? `Pesticides: <b>${pesticides}</b><br/>
                 Cancer: <b>${cancer}</b>`
              : "No data"
          }
        
   
          `}
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
