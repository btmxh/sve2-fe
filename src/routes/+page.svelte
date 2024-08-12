<script lang="ts">
  import ButtonBar, {
    PlaybackCommand,
  } from "../lib/components/ButtonBar.svelte";
</script>

<main class="container">
  <ButtonBar
    on:playback={(e) => console.debug(e.detail == PlaybackCommand.Pause)}
    on:modechange={(e) => alert(e.detail)}
  />
</main>

<style>
</style>
