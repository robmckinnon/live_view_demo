const requestMidiAccess = (navigator) => {
  navigator.requestMIDIAccess().then((midiAccess) => {
    console.log('hi')
    console.log(JSON.stringify(midiAccess))
    // const gain = function (vel) { return vel / 127; };
    midiAccess.outputs.forEach((midiOutput) => {
      // this.pushEvent(x, y)
      console.log(midiOutput.id);
      console.log(midiOutput.type);
      console.log(midiOutput.name);
      // this.registerOutput(midiOutput);
    })
    midiAccess.inputs.forEach((midiInput) => {
      // this.listenToInput(midiInput);
    })
  })
}

export default requestMidiAccess
