import util from "util"
const WebAudioTinySynth = require('webaudio-tinysynth')

const inputs = {}
const outputs = {}

// Summary of MIDI Messages:
// https://www.midi.org/specifications-old/item/table-1-summary-of-midi-message


// Active Sensing. This message is intended to be sent repeatedly to tell the
// receiver that a connection is alive. Use of this message is optional.
// We have found that the problems introduced by active sensing outweigh its
// benefits, therefore we filter out active sensing messages.
const ACTIVE_SENSING = 254 // 11111110

// Timing Clock. This message sent 24 times per quarter note when
// synchronization is required.
const TIMING_CLOCK = 248 // 11111000

const MESSAGE = "m"
const synth = new WebAudioTinySynth()

// 1001nnnn
const note_on = 144
// 1000nnnn
const note_off = 128
// 1011nnnn
const control_change = 176
// 1100nnnn
const program_change = 192

const STATUS_BYTE = 0xf0
const CHANNEL_BYTE = 0x0f
const NOTE_OFF = 0x80
const NOTE_ON = 0x90

const onMidiMessageHandler = (ctx) => {
  return function (msg) {
    if (!msg.data) {
      console.error(util.inspect(msg))
      return
    }
    if (msg.data.length === 1) {
      switch (msg.data[0]) {
        case ACTIVE_SENSING:
          return // ignore active sensing messages
        case TIMING_CLOCK:
          return // ignore timing clock for now
        default:
          console.log(util.inspect(msg.data)) // log other system messages for now
      }
    } else {
      ctx.pushEvent(MESSAGE, {
        d: msg.data,
        t: msg.timeStamp,
        i: msg.target.id // msg.target is the midiInput port object
      })
      const messageCode = msg.data[0] & STATUS_BYTE
      const channel = msg.data[0] & CHANNEL_BYTE;
      if (messageCode === NOTE_ON) {
        synth.noteOn(channel, msg.data[1], msg.data[2])
      } else if (messageCode === NOTE_OFF) {
        synth.noteOff(channel, msg.data[1])
      }
    }
  }
}

const midiPortState = (port) => {
  return {
    id: port.id,
    manufacturer: port.manufacturer,
    name: port.name,
    type: port.type,
    version: port.version,
    state: port.state,
    connection: port.connection
  }
}

const setPort = (port, collection, ctx, event) => {
  collection[port.id] = port
  ctx.pushEvent(event, midiPortState(port))
}

const INPUT = 'input'
const OUTPUT = 'output'
const MIDI_INPUT = 'midi_input'
const MIDI_OUTPUT = 'midi_output'

const updatePort = (port, ctx) => {
  if (port.type === INPUT) {
    if (!inputs[port.id]) {
      port.onmidimessage = onMidiMessageHandler(ctx)
    }
    setPort(port, inputs, ctx, MIDI_INPUT)
  } else if (port.type === OUTPUT) {
    setPort(port, outputs, ctx, MIDI_OUTPUT)
  } else {
    console.error(port.name)
  }
}

const requestMidiAccess = async (navigator, ctx) => {
  try {
    const midiAccess = await navigator.requestMIDIAccess()
    console.log(util.inspect(midiAccess))

    midiAccess.inputs.forEach(midiInput => updatePort(midiInput, ctx))
    midiAccess.outputs.forEach(midiOutput => updatePort(midiOutput, ctx))
    midiAccess.onstatechange = ({ port }) => updatePort(port, ctx)
  } catch (err) {
    console.error(util.inspect(err))
  }
}

export default requestMidiAccess
