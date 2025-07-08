<script>
  import Window from "./components/Window.svelte";
  import Map from "./components/Map.svelte";
  import Legend from "./components/Legend.svelte";

  import { interpolateRgb } from "d3-interpolate";
  import { scaleLinear } from "d3-scale";
  import { ticks } from "d3-array";

  import { max } from "d3-array";

  import data from "./data/data.json";

  // Handle responsive iframes for embeds
  import pym from "pym.js";

  new pym.Child({
    polling: 500,
  });

  let overlayInfo;
  let marker = null;

  let width;

  const maxes = {
    count: max(data, (d) => d.count),
    share: max(data, (d) => d.share),
  };

  const createCustomColorScale = (colors, max) => {
    return scaleLinear()
      .domain([0, max]) // Scale input from 0 to 1
      .range(colors) // Interpolate between white and the provided color
      .interpolate(interpolateRgb); // Use RGB interpolation
  };

  const colorScales = {
    count: createCustomColorScale(["#e5f5e0", "#6DA34D"], maxes.count), // Replace with your desired hex color for "count"
    share: createCustomColorScale(["#deebf7", "#548687"], maxes.share), // Replace with your desired hex color for "share"
  };

  let selectedVariable = "count";


  function generateNiceTicks(maxValue, tickCount) {
    // Use d3.ticks to generate the tick values
    const ticksGenerator = ticks(0, maxValue, tickCount);

    // Ensure the tick values extend to cover the range nicely
    const niceScale = scaleLinear().domain([0, maxValue]).nice(tickCount);

    return niceScale.ticks(tickCount);
  }

  const buckets = {
    count: generateNiceTicks(maxes.count, 5),
    share: generateNiceTicks(maxes.share, 5),
  };

  const colors = {
    count: generateNiceTicks(maxes.count, 5).map((c) => colorScales.count(c)),
    share: generateNiceTicks(maxes.share, 5).map((c) => colorScales.share(c)),
  };

  const suffixes = {
    count: "",
    share: "%",
  };

  const legendTitles = {
    count: "Number of beavers killed",
    share: "Percentage of total beavers killed",
  };
</script>

<Window />
<!-- Outer div must have class 'chart-container' don't change -->
<div class="chart-container">
  <h1 class="headline">Beavers killed by USDA Wildlife Services in 2023</h1>
  <p class="dek">
    <!-- <span class="town orange" /> Corona is a community isolated from its state
    due to the winding path of the Mississippi that forms the
    <span class="border" />
    border between Arkansas, Tennessee and Mississippi.
    <span class="town white" />Indicate other towns along the Mississippi River. -->
  </p>

  <p class="sr-only">
    A map showing river towns along the border of Arkansas, Tennessee and
    Mississippi.
  </p>

  <div class="controls">
    <div class="toggle">
      <span class="dek">Shade states by</span>
      <div class="buttons">
        <button
          class:active={selectedVariable == "count"}
          style:--color={colors.count[3]}
          on:click={() => (selectedVariable = "count")}>Number of beavers</button
        >
        <button
          class:active={selectedVariable == "share"}
          style:--color={colors.share[3]}
          on:click={() => (selectedVariable = "share")}>Percentage of beavers</button
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
    <Map {width} {data} {colorScales} {selectedVariable} />
  </div>

  <div class="credit">
    Graphic by Jared Whalen /
    <a target="_blank" href="https://agwaterdesk.org/">Ag & Water Desk</a>
  </div>
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
