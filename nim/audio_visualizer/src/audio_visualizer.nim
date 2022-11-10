import nimraylib_now
import openal
import math

const
  windowWidth = 1600
  windowHeight = 900

  audioBufferLen = 4096*8 # should be larger than windowWidth
  numPoints = 800

## audio stuff
echo "Using audio input device \"" & $(alcGetString(nil, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER)) & "\""

discard alGetError() # clean slate of errors

let device = alcCaptureOpenDevice(nil, 44100, AL_FORMAT_MONO16, audioBufferLen + 1024)
if (let err = alGetError(); err != AL_NO_ERROR):
  echo "error opening capture device: " & $alGetString(err)

alcCaptureStart(device)

var
  audioData: array[audioBufferLen, int16]
  averagedAudioData: array[numPoints, float64]

  # points: array[windowWidth div 4, Vector2]
  points: array[numPoints, Vector2]
  otherPoints: array[numPoints, Vector2]

  rotationCoefficient = 0.float64

# captureAudio captures audio samples if available, and returns whether or not samples were retrieved
proc captureAudio(): bool =
  const samplesPerCapture = 1024

  var availableSamples: ALCint
  alcGetIntegerv(device, ALC_CAPTURE_SAMPLES, sizeof(ALCint), addr(availableSamples))

  # If we don't have enough samples yet, return early
  if availableSamples < samplesPerCapture:
    return false

  availableSamples = min(availableSamples, audioBufferLen)

  # If we have audioBufferLen samples ready, we don't need to bother moving old data since it'll all be over-written
  if availableSamples < audioBufferLen:
    let
      startOfMemoryToCopy = cast[pointer](addr(audioData[availableSamples]))
      sizeOfMemoryToCopy = (audioBufferLen - availableSamples) * sizeof(int16)

    moveMem(addr(audioData), startOfMemoryToCopy, sizeOfMemoryToCopy)

  let dst = cast[pointer](addr(audioData[audioBufferLen - availableSamples]))
  alcCaptureSamples(device, dst, availableSamples)
  return true

# processAudio processes the global audioData array
proc processAudio() =
  let samplesPerPoint = audioBufferLen div numPoints

  # Process audio data by sampling down to `numPoints`
  for i in 0..numPoints-1:
    var total = 0.float64
    for j in (i*samplesPerPoint)..(i*samplesPerPoint)+samplesPerPoint:
      total += (audioData[j] / 32767)

    averagedAudioData[i] = total / samplesPerPoint.float64

  for i in 0..len(points)-1:
    let angle = (i.float64 / len(points).float64) * 2 * PI
    let r = (averagedAudioData[i]) * 200.float64 + 400.float64

    points[i].x = (windowWidth / 2) + (r * cos(rotationCoefficient + angle))
    points[i].y = (windowHeight / 2) + (r * sin(rotationCoefficient + angle))

    let percent = (1 - (i.float64 / len(points).float64))
    var otherR = percent * 400
    otherR += averagedAudioData[i]*200# *max(0.1, percent)

    otherPoints[i].x = (windowWidth / 2) + (otherR * cos(rotationCoefficient + angle*3)) #+ ((averagedAudioData[i]*200) * sin(-angle * 4))
    otherPoints[i].y = (windowHeight / 2) + (otherR * sin(rotationCoefficient + angle*3))# + ((averagedAudioData[i]*200) * cos(angle * 4))

    # arc across the screen
    # otherPoints[i].x = (windowWidth/2) + (windowWidth/2 * cos(angle / 2)) + ((r-200) * cos(angle / 2))
    # otherPoints[i].y = (windowHeight) + ((windowHeight/4) * sin(-angle / 2)) + ((r-200) * sin(-angle / 2))



## Raylib init
initWindow(windowWidth, windowHeight, "hello from nim")
setTargetFPS(144)

while not windowShouldClose():
  if captureAudio():
    processAudio()

  var totalVolume: float64
  for v in averagedAudioData:
    totalVolume += abs(v)

  rotationCoefficient += totalVolume / len(averagedAudioData).float64
  if rotationCoefficient > 2 * PI:
    rotationCoefficient -= 2 * PI

  beginDrawing:
    clearBackground(Black)

    for i in 1..len(otherPoints)-1:
      let percent = i.float64 / len(otherPoints).float64

      var color = Purple
      color.r = (color.r.float * percent).uint8
      color.g = (color.g.float * percent).uint8
      color.b = (color.b.float * percent).uint8

      drawLineEx(otherPoints[i-1], otherPoints[i], 1+(3*percent).cfloat, color)

    for i in 1..len(points)-1:
        var percent = (i.float64*2 / len(otherPoints).float64)
        if percent < 0:
          percent = -percent
        while percent > 1:
          percent = 2 - percent

        var color = Purple
        color.r = (color.r.float * percent).uint8
        color.g = (color.g.float * percent).uint8
        color.b = (color.b.float * percent).uint8

        if percent > 1:
          color = Red
        elif percent < 0:
          color = Blue

        drawLineEx(points[i-1], points[i], 4, color)

    # drawFps(12, 12)
    # drawText("delta rot coef: " & $(totalVolume / len(averagedAudioData).float64), 12, 32, 24, RayWhite)

alcCaptureStop(device)
discard alcCaptureCloseDEvice(device)
