<template>
  <fieldset class="fieldset">
    <legend>Source</legend>
    <div class="horizontal-left-content align-start separate-bottom">
      <smart-selector
        class="full_width"
        model="sources"
        klass="CollectionObject"
        target="CollectionObject"
        pin-section="Sources"
        pin-type="Source"
        label="cached"
        v-model="source"
      />
      <v-lock
        class="margin-small-left"
        v-model="lockCOs"
      />
    </div>
    <div
      v-if="source"
      class="field horizontal-left-content middle"
    >
      <span v-html="source.cached" />
      <button
        type="button"
        class="button circle-button btn-undo button-default"
        @click="source = undefined"
      />
    </div>
    <div class="field">
      <input
        type="text"
        class="pages"
        placeholder="Pages"
        v-model="pages"
      >
      <label>
        <input
          v-model="is_original"
          type="checkbox"
        >
        Is original
      </label>
    </div>
    <button
      type="button"
      class="button normal-input button-default"
      @click="saveCitation"
      :disabled="!source"
    >
      Add
    </button>
  </fieldset>
</template>

<script>

import SmartSelector from 'components/ui/SmartSelector.vue'
import makeCitationObject from 'factory/Citation.js'
import VLock from 'components/ui/VLock'
import { COLLECTION_OBJECT } from 'constants/index.js'

export default {
  components: {
    SmartSelector,
    VLock
  },

  props: {
    lock: {
      type: Boolean
    }
  },

  emits: [
    'update:lock',
    'onAdd'
  ],

  computed: {
    lockCOs: {
      get () {
        return this.lock
      },
      set (value) {
        this.$emit('update:lock', value)
      }
    }
  },

  data: () => ({
    source: undefined,
    pages: undefined,
    is_original: undefined
  }),

  methods: {
    saveCitation () {
      this.$emit('onAdd', {
        ...makeCitationObject(COLLECTION_OBJECT),
        citation_source_body: this.getCitationString(this.source),
        pages: this.pages,
        source_id: this.source.id,
        is_original: this.is_original
      })

      this.source = undefined
      this.is_original = undefined
      this.pages = undefined
    },

    getCitationString (source) {
      const author = [source.cached_author_string, source.year].filter(Boolean).join(', ')

      return this.pages
        ? `${author}:${this.pages}`
        : author
    }
  }
}
</script>
