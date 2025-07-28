<script>
  /**
   * @typedef {Object} Props
   * @property {any} [buckets] - Array of bucket thresholds (e.g., [0, 1000, 2000, 3000, 4000, 5000])
   * @property {any} [colors] - Array of colors corresponding to the buckets
   * @property {string} [title] - Title for the legend
   * @property {string} [suffix] - Optional suffix (e.g., '%' or '')
   */

  /** @type {Props} */
  let {
    buckets = [],
    colors = [],
    title = "",
    suffix = ""
  } = $props();

  let width = 200;
  let margin = 0;

  // Helper to abbreviate large numbers
  const formatNumber = (value) => {
  if (value >= 1_000_000) {
    const formatted = (value / 1_000_000).toFixed(1);
    return `${formatted.endsWith('.0') ? formatted.slice(0, -2) : formatted}M`;
  }
  if (value >= 1_000) {
    const formatted = (value / 1_000).toFixed(1);
    return `${formatted.endsWith('.0') ? formatted.slice(0, -2) : formatted}K`;
  }
  return value.toString();
};

  // Calculate the width of each bucket
  let bucketWidth = $derived(width / (buckets.length - 1));
</script>

<div class="legend">
  {#if title}
    <div class="legend-title">{title}</div>
  {/if}
  <svg width={width + margin * 2 + (bucketWidth + 15)+ 15} height="40">
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
