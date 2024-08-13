<script lang="ts" context="module">
  export enum ViewMode {
    Node = "node",
    Timeline = "timeline",
  }

  export enum PlaybackCommand {
    Play = "play",
    Pause = "pause",
  }
</script>

<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import { faPause, faPlay } from "@fortawesome/free-solid-svg-icons";
  import Fa from "svelte-fa";

  const dispatch = createEventDispatcher<{
    modechange: ViewMode;
    playback: PlaybackCommand;
  }>();
</script>

<nav>
  <ul class="nav-btns">
    <li>
      <input
        id="nav-btn-node-view"
        type="radio"
        name="nav-btn"
        on:click={() => dispatch("modechange", ViewMode.Node)}
        checked
      />
      <label for="nav-btn-node-view">Node View</label>
    </li>
    <li>
      <input
        id="nav-btn-timeline-view"
        type="radio"
        name="nav-btn"
        on:click={() => dispatch("modechange", ViewMode.Timeline)}
      />
      <label for="nav-btn-timeline-view">Timeline View</label>
    </li>
  </ul>

  <section class="playback-btns">
    <button on:click={() => dispatch("playback", PlaybackCommand.Play)}>
      <Fa icon={faPlay}></Fa>
    </button>

    <button on:click={() => dispatch("playback", PlaybackCommand.Pause)}>
      <Fa icon={faPause}></Fa>
    </button>
  </section>
</nav>

<style lang="scss">
  nav {
    background-color: var(--secondary-color);

    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: stretch;

    .nav-btns {
      display: flex;
      flex-direction: row;
      justify-content: flex-start;
      align-items: stretch;

      li {
        display: flex;
        gap: 0;
        padding-left: 0.5rem;
        padding-right: 0.5rem;

        input {
          display: none;
        }

        label {
          display: inline-block;
          line-height: 1.5rem;
          user-select: none;
          -webkit-user-select: none;
        }

        &:hover {
          background-color: var(--accent-color-light);
        }

        &:has(input:checked) {
          background-color: var(--accent-color);
        }
      }
    }

    .playback-btns {
      display: flex;
      flex-direction: row;
      justify-content: center;
      align-items: center;
      gap: 0.25rem;
      padding: 0.1rem;

      button {
        display: flex;
        align-items: center;
        justify-content: center;

        border-radius: 4px;

        font-size: 0.9rem;
        width: 1.2rem;
        height: 1.2rem;
        padding: 0.1rem;

        &:hover {
          background-color: var(--secondary-color-light);
        }

        &:active {
          background-color: var(--secondary-color-dark);
        }
      }
    }
  }
</style>
