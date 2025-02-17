<template>
  <div
    id="vue-clipboard-app"
    class="full_width">
    <ul class="slide-panel-category-content">
      <li
        v-for="(clip, index) in clipboard"
        :key="index"
        class="slide-panel-category-item">
        <div class="full_width padding-large-right">
          <p>Shortcut: <b>{{ pasteKeys.join(' + ') }} + {{ index }}</b></p>
          <div class="middle">
            <textarea
              class="full_width"
              rows="5"
              v-model="clipboard[index]"
              @blur="saveClipboard"/>
          </div>
        </div>
      </li>
    </ul>
    <p class="slide-panel-category-content">
      Use <b>{{ actionKey }} + {{ keyCopy }} + Number</b> to copy a text to the clipboard box
    </p>
  </div>
</template>
<script>

import { ProjectMember } from 'routes/endpoints'

export default {
  name: 'ClipboardApp',

  computed: {
    actionKey () {
      return navigator.platform.indexOf('Mac') > -1
        ? 'Control'
        : 'Alt'
    },

    isLinux () {
      return navigator.platform.indexOf('Linux') > -1
    },

    pasteKeys () {
      return this.isLinux
        ? [this.actionKey, 'Control']
        : [this.actionKey]
    }
  },

  data () {
    return {
      clipboard: {
        1: '',
        2: '',
        3: '',
        4: '',
        5: ''
      },
      keys: [],
      keyCopy: 'C'
    }
  },

  created () {
    document.addEventListener('turbolinks:load', () => {
      window.removeEventListener('keydown', this.keyPressed)
      window.removeEventListener('keyup', this.removeKey)
    })

    window.addEventListener('keydown', this.keyPressed)
    window.addEventListener('keyup', this.removeKey)

    ProjectMember.clipboard().then(response => {
      Object.assign(this.clipboard, response.body.clipboard)
    })
  },

  methods: {
    isInput () {
      return document.activeElement.tagName === 'INPUT' ||
          document.activeElement.tagName === 'TEXTAREA'
    },

    keyPressed (event) {
      const { code, key } = event
      const keyPressed = String(Object.keys(this.clipboard).findIndex(keyCode => `Digit${keyCode}` === code) + 1)
      const isClipboardKey = Object.keys(this.clipboard).includes(key)
      const iskeyCopyPressed = !!this.keys.find(key => key.toUpperCase() === this.keyCopy)

      this.addKey(isClipboardKey ? keyPressed : key)

      if ((this.keys.includes(this.actionKey) && event.getModifierState(this.actionKey)) && isClipboardKey) {
        if (iskeyCopyPressed) {
          this.setClipboard(key)
        } else if (this.pasteKeys.every(key => this.keys.includes(key))) {
          this.pasteClipboard(key)
        }
        event.preventDefault()
      }
    },

    pasteClipboard (clipboardIndex) {
      if (this.isInput() && this.clipboard[clipboardIndex]) {
        const position = document.activeElement.selectionStart
        const text = document.activeElement.value
        document.activeElement.value = text.substr(0, position) + this.clipboard[clipboardIndex] + text.substr(position)
        document.activeElement.dispatchEvent(new CustomEvent('input'))
      }
    },

    saveClipboard () {
      ProjectMember.updateClipboard(this.clipboard).then(response => {
        this.clipboard = response.body.clipboard
      })
    },

    setClipboard (index) {
      const textSelected = this.isInput()
        ? document.activeElement.value
        : window.getSelection().toString()

      if (textSelected.length > 0) {
        this.clipboard[index] = textSelected
        this.saveClipboard()
      }
    },

    addKey (key) {
      if (!this.keys.includes(key)) {
        this.keys.push(key)
      }
    },

    removeKey ({ key }) {
      const position = this.keys.findIndex(keyStore => keyStore === key)

      if (position > -1) {
        this.keys.splice(position, 1)
      }
    }
  }
}
</script>
