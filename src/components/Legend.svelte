<script>
  export let buckets = []; // Array of bucket thresholds (e.g., [0, 1000, 2000, 3000, 4000, 5000])
  export let colors = []; // Array of colors corresponding to the buckets
  export let title = ""; // Title for the legend
  export let suffix = ""; // Optional suffix (e.g., '%' or '')

  let width = 200;
  let margin = 0;

  // Helper to abbreviate large numbers
  const formatNumber = (value) => {
    if (value >= 1_000_000) return `${Math.round(value / 1_000_000)}M`;
    if (value >= 1_000) return `${Math.round(value / 1_000)}K`;
    return value;
  };

  // Calculate the width of each bucket
  $: bucketWidth = width / (buckets.length - 1);
</script>

<div class="legend">
  {#if title}
    <div class="legend-title">{title}</div>
  {/if}
  <svg width={width + margin * 2 + (bucketWidth + 15)} height="40">
    <g transform="translate({margin}, 0)">
      {#each buckets.slice(0, -1) as bucket, i}
        <!-- Draw bucket rectangles -->
        <rect
          x={i * bucketWidth}
          y="0"
          width={bucketWidth}
          height="15"
          fill={colors[i]}
          stroke="#fff"
          stroke-width="1"
        />
      {/each}

      <!-- Draw bucket labels -->
      {#each buckets as bucket, i}
        {#if i && i < buckets.length - 1}
          <text
            x={i * bucketWidth}
            y="25"
            text-anchor="middle"
            font-size="12"
            fill="#333"
          >
            {formatNumber(bucket)}{suffix}
          </text>
        {/if}
      {/each}

      <g>
        <rect
          x={buckets.slice(0, -1).length * bucketWidth + 15}
          y="0"
          width={30}
          height="15"
          fill={"#ddd"}
          stroke="#fff"
          stroke-width="1"
        />

        <text
          x={buckets.slice(0, -1).length * bucketWidth + 30}
          y="25"
          text-anchor="middle"
          font-size="12"
          fill="#333"
        >
          No data
        </text>
      </g>
    </g>
  </svg>
</div>

<style>
  .legend {
    font-family: Arial, sans-serif;
  }
  .legend-title {
    font-size: 12px;
    font-weight: bold;
  }
  text {
    dominant-baseline: middle;
  }
</style>
