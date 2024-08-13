<script lang="ts">
  import ButtonBar, {
    PlaybackCommand,
  } from "../lib/components/ButtonBar.svelte";

  async function evalLuaSve2(cmd: string): Promise<any> {
    const res = await fetch("http://localhost:1234/eval", {
      method: "POST",
      body: cmd,
    });

    if (res.status < 200 || res.status >= 400) {
      const error = await res.text();
      throw new Error("error evaluating lua code: " + error);
    }

    return await res.json();
  }

  async function playbackCallback(cmd: PlaybackCommand) {
    try {
      switch (cmd) {
        case PlaybackCommand.Play:
          await evalLuaSve2("sve.ctx.play()");
          break;
        case PlaybackCommand.Pause:
          await evalLuaSve2("sve.ctx.pause()");
          break;
      }
    } catch (err) {
      alert(err);
    }
  }
</script>

<main class="container">
  <ButtonBar
    on:playback={(e) => playbackCallback(e.detail)}
    on:modechange={(e) => alert(e.detail)}
  />
</main>

<style>
</style>
