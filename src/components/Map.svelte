<script>
  import { onMount } from "svelte";

  import { geoAlbersUsa, geoPath } from "d3-geo";

  import tippy, { followCursor } from "tippy.js";
  import "tippy.js/dist/tippy.css";
  import "tippy.js/themes/light.css";

  import { extent } from "d3-array";

  import geoJson from "../data/states.json";

  export let data;
  export let width = 800;
  export let colorScales;
  export let selectedVariable = "count";

  $: height = width * 0.6;

  let paths = [];

  $: projection = geoAlbersUsa().fitSize([width, height], geoJson);
  $: pathGenerator = geoPath().projection(projection);

  $: updatePaths = (fillVariable) => {
    // Merge data into GeoJSON features
    const mergedData = geoJson.features.map((feature) => {
      const stateData = data.find((d) => d.state === feature.properties.NAME);
      feature.properties.count = stateData ? stateData.count : null;
      feature.properties.share = stateData ? stateData.share : null;
      feature.properties.value = stateData ? stateData[fillVariable] : null;
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
      state: d.properties.NAME,
      count: d.properties.count?.toLocaleString(),
      share: d.properties.share,
      fill:
        d.properties.value !== null
          ? colorScales[fillVariable](d.properties.value)
          : "#ddd",
    }));
  };

  $: updatePaths(selectedVariable);

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
    {#each paths as { d, state, count, share }}
      <path
        {d}
        fill="transparent"
        stroke="#000"
        stroke-width="1"
        data-tippy-content={`
          <b style="font-size: 1.2em;">${state}</b><br/>
          ${
            state && count
              ? `Number of beavers killed: <b>${count}</b><br/>
                 Percentage of total beavers killed: <b>${share}%</b>`
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
