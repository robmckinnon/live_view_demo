import util from "util"

const inputs = {}
const outputs = {}

const midiPortState = (midiPort) => {
  return {
    id: midiPort.id,
    manufacturer: midiPort.manufacturer,
    name: midiPort.name,
    type: midiPort.type,
    version: midiPort.version,
    state: midiPort.state,
    connection: midiPort.connection
  }
}

const requestMidiAccess = (navigator, ctx) => {
  navigator.requestMIDIAccess().then((midiAccess) => {
    console.log('hi')
    console.log(JSON.stringify(midiAccess))
    // const gain = function (vel) { return vel / 127; };
    midiAccess.inputs.forEach((midiInput) => {
      inputs[midiInput.id] = midiInput
      // this.listenToInput(midiInput);
      ctx.pushEvent("midi_input", midiPortState(midiInput))
    })
    midiAccess.outputs.forEach((midiOutput) => {
      // this.pushEvent(x, y)
      outputs[midiOutput.id] = midiOutput
      // this.registerOutput(midiOutput);
      ctx.pushEvent("midi_output", midiPortState(midiOutput))
    })
  })
}

export default requestMidiAccess
