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

const addPort = (port, collection, ctx, event) => {
  collection[port.id] = port
  ctx.pushEvent(event, midiPortState(port))
}

const requestMidiAccess = async (navigator, ctx) => {
  const midiAccess = await navigator.requestMIDIAccess()
  console.log(JSON.stringify(midiAccess))

  midiAccess.inputs.forEach((midiInput) => {
    addPort(midiInput, inputs, ctx, "midi_input")
  })

  midiAccess.outputs.forEach((midiOutput) => {
    addPort(midiOutput, outputs, ctx, "midi_output")
  })

  midiAccess.onstatechange = (event) => {
    const { port } = event;
    if (port.type === 'input') {
      addPort(port, inputs, ctx, "midi_input")
    } else if (port.type === 'output') {
      addPort(port, outputs, ctx, "midi_output")
    } else {
      console.log(port.name);
      alert(event);
    }
  }
}

export default requestMidiAccess
