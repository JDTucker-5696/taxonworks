<template>
  <div>
    <h3>Collection objects</h3>
    <autocomplete
      url="/collection_objects/autocomplete"
      param="term"
      label="label_html"
      placeholder="Search a collection object..."
      clear-after
      @getItem="addCo($event.id)"
    />
    <div class="field separate-top">
      <ul class="no_bullets table-entrys-list">
        <li
          class="middle flex-separate list-complete-item"
          v-for="(otu, index) in coStore"
          :key="otu.id">
          <span v-html="otu.object_tag"/>
          <span
            class="btn-delete button-circle button-default"
            @click="removeCo(index)"/>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>

import Autocomplete from 'components/ui/Autocomplete'
import { CollectionObject } from 'routes/endpoints'
import { URLParamsToJSON } from 'helpers/url/parse.js'

export default {
  components: { Autocomplete },

  props: {
    modelValue: {
      type: Array,
      required: true
    }
  },

  emits: ['update:modelValue'],

  data () {
    return {
      coStore: []
    }
  },

  watch: {
    coStore (newVal) {
      this.$emit('update:modelValue', newVal.map(otu => otu.id))
    }
  },

  created () {
    const params = URLParamsToJSON(location.href)
    if (params.collection_object_id) {
      params.collection_object_id.forEach(id => {
        this.addCo(id)
      })
    }
  },

  methods: {
    removeCo (index) {
      this.coStore.splice(index, 1)
    },
    addCo (id) {
      CollectionObject.find(id).then(({ body }) => {
        this.coStore.push(body)
      })
    }
  }
}
</script>
