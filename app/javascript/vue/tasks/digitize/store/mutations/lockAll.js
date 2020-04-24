export default function(state, value) {
  let allLock = state.settings.locked
  let isLocked = !state.settings.isLocked

  function setValueForAll(lockOption, value) {
    Object.keys(lockOption).forEach(key => {
      if(typeof lockOption[key] === 'object') {
        Object.keys(lockOption[key]).forEach(lvl2 => {
          lockOption[key][lvl2] = value
        })
      }
      else {
        lockOption[key] = value
      }
    })
    return lockOption
  }
  state.settings.locked = setValueForAll(allLock, isLocked)
  state.settings.isLocked = isLocked
}