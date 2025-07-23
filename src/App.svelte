

<script>
  import Window from "./components/Window.svelte";
  import Map from "./components/Map.svelte";
  import Legend from "./components/Legend.svelte";

  import { interpolateRgb } from "d3-interpolate";
  import { scaleLinear } from "d3-scale";
  import { ticks } from "d3-array";

  import { max } from "d3-array";

  import data from "./data/data.json";
console.log(data[0].fips)
  // Handle responsive iframes for embeds
  import pym from "pym.js";

  new pym.Child({
    polling: 500,
  });


  let width = $state();

 const propertyMap = {
    pesticides: "total_pest_per_sqmi",
    cancer: "general_cancer_rate",
  };

  const maxes = {
    pesticides: max(data, (d) => d[propertyMap.pesticides]),
    cancer: max(data, (d) => d[propertyMap.cancer]),
  };

  const createCustomColorScale = (colors, max) => {
    return scaleLinear()
      .domain([0, max]) // Scale input from 0 to 1
      .range(colors) // Interpolate between white and the provided color
      .interpolate(interpolateRgb); // Use RGB interpolation
  };

 

  const colorScales = {
    pesticides: createCustomColorScale(["#FEF5C1", "#FFE135"], maxes.pesticides), // Replace with your desired hex color for "pesticides"
    cancer: createCustomColorScale(["#97bfeb", "#135297"], maxes.cancer), // Replace with your desired hex color for "cancer"
  };


  let selectedVariable = $state("pesticides");

  function generateNiceTicks(maxValue, tickCount) {
    // Use d3.ticks to generate the tick values
    const ticksGenerator = ticks(0, maxValue, tickCount);

    // Ensure the tick values extend to cover the range nicely
    const niceScale = scaleLinear().domain([0, maxValue]).nice(tickCount);

    return niceScale.ticks(tickCount);
  }

  const buckets = {
    pesticides: generateNiceTicks(maxes.pesticides, 5),
    cancer: generateNiceTicks(maxes.cancer, 5),
  };

  const colors = {
    pesticides: generateNiceTicks(maxes.pesticides, 5).map((c) => colorScales.pesticides(c)),
    cancer: generateNiceTicks(maxes.cancer, 5).map((c) => colorScales.cancer(c)),
  };

  const suffixes = {
    pesticides: "",
    cancer: "",
  };

  const legendTitles = {
    pesticides: "Kilograms spread per square mile",
    cancer: "Cases per 100K",
  };
</script>

<Window />
<!-- Outer div must have class 'chart-container' don't change -->
<div class="chart-container">
  <h1 class="headline">Cancer rates and Pesticide Usage by county</h1>

  <div class="dek">TKTKTKTK</div> 

  <p class="sr-only"></p>

  <div class="controls">
    <div class="toggle">
      <span class="dek">Shade states by</span>
      <div class="buttons">
        <button
          class:active={selectedVariable == "pesticides"}
          style:--color={colors.pesticides[3]}
          onclick={() => (selectedVariable = "pesticides")}>Pesticides per square mile (kg)</button
        >
        <button
          class:active={selectedVariable == "cancer"}
          style:--color={colors.cancer[3]}
          onclick={() => (selectedVariable = "cancer")}
          >Cancer rate per 100k</button
        >
      </div>
    </div>
  </div>

  <Legend
    buckets={buckets[selectedVariable]}
    colors={colors[selectedVariable]}
    title={legendTitles[selectedVariable]}
    suffix={suffixes[selectedVariable]}
  />

  <div id="g-viz" bind:clientWidth={width}>
    <Map {width} {data} {colorScales} {selectedVariable} {propertyMap} />
  </div>

  <!-- <div class="credit">
    Graphic by Jared Whalen /
    <a target="_blank" href="https://agwaterdesk.org/">Ag & Water Desk</a>
  </div> -->
</div>

<style lang="scss">
  .chart-container {
    max-width: 800px;
    width: 100%;
    // padding: 1rem;
  }

  #g-viz {
    position: relative;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
  }

  .controls {
    display: flex;
    align-items: start;
    gap: 2rem;
    font-size: bold;

    .toggle {
      display: flex;
      gap: 0.5rem;
    }
  }

  button {
    background: transparent;
    border: 2px solid transparent;
    position: relative;
    padding: 3px 6px;
    font-weight: bold;
    cursor: pointer;

    &:hover {
      &::before {
        opacity: 0.5;
      }
    }

    &.active {
      border: 2px solid;
      &::before {
        opacity: 0.5;
      }
    }

    &::before {
      content: "";
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: var(--color);
      opacity: 0.3;
      z-index: -1;
    }
  }

  :global {
    .town {
      $size: 12px;
      margin-left: calc($size + 4px);
      position: relative;

      &.orange {
        &::after {
          background: #f1b82d;
        }
      }

      &.white {
        &::after {
          background: #fff;
        }
      }

      &::after {
        width: $size;
        height: $size;
        content: "";
        border: 1px;
        position: absolute;
        left: calc($size * -1 - 2px);
        top: 53%;
        transform: translateY(-50%);
        border: 2px solid;
        border-radius: 100%;
      }
    }

    .border {
      $size: 12px;
      margin-left: calc($size + 4px);
      position: relative;

      &::after {
        width: $size;
        height: 1.5px;
        content: "";
        border: 1px;
        position: absolute;
        left: calc($size * -1 - 2px);
        top: 55%;
        transform: translateY(-50%);
        background: #ff6542;
      }
    }
  }
</style>
