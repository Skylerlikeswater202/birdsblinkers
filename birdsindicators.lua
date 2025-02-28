ui.setAsynchronousImagesLoading(true)


-- Define colors using rgbm format (R, G, B, Alpha)
local grayBackground = rgbm(0.2, 0.2, 0.2, 1)  -- Gray background
local greenIndicator = rgbm(0, 1, 0, 1)        -- Solid green for indicators
local whiteLine = rgbm(1, 1, 1, 1)             -- White for the dividing line


-- Flash timer setup
local flashState = true  -- Start with ON (green) when signal is activated
local flashTimer = 0
local isAnySignalActive = false  -- Track if any signal is active


function script.update(dt)
  -- Update flash timer every frame, but only if a signal is active
  if isAnySignalActive then
    flashTimer = flashTimer + dt
    if flashTimer >= 0.5 then  -- Flash every 0.5 seconds (0.25s on, 0.25s off)
      flashState = not flashState
      flashTimer = 0
    end
  else
    flashState = true  -- Reset to ON when signal becomes active again, but only draw if active
    flashTimer = 0
  end
end


function script.windowMain(dt)
  -- Get the current state of the car's turn signals and hazard lights
  local leftActive = ac.getCar().turningLeftLights
  local rightActive = ac.getCar().turningRightLights
  local hazardActive = ac.getCar().hazardLights


  -- Check if any signal is active
  isAnySignalActive = leftActive or rightActive or hazardActive


  -- Define base box dimensions (original size)
  local baseWidth = 200
  local baseHeight = 100
  local marginFactor = 20 / baseWidth  -- Margin as a fraction of width for scaling


  -- Get window size for scaling
  local windowWidth = ui.windowWidth()
  local windowHeight = ui.windowHeight()


  -- Calculate scale factor based on window size, maintaining aspect ratio (2:1)
  local scale = math.min(windowWidth / baseWidth, windowHeight / baseHeight)
  local scaledWidth = baseWidth * scale
  local scaledHeight = baseHeight * scale
  local scaledMargin = scaledWidth * marginFactor  -- Scale the margin proportionally


  -- Center the box in the window
  local startX = (windowWidth - scaledWidth) / 2
  local startY = (windowHeight - scaledHeight) / 2


  -- Draw the main outline (gray background)
  ui.beginOutline()
  ui.drawRectFilled(vec2(startX, startY), vec2(startX + scaledWidth, startY + scaledHeight), grayBackground)


  -- Draw the left half (if active, start ON, then flash)
  if leftActive or hazardActive then
    if flashState then  -- Only draw when flashState is true (ON), but it starts ON
      ui.drawRectFilled(
        vec2(startX + scaledMargin, startY + scaledMargin),
        vec2(startX + scaledWidth/2 - scaledMargin, startY + scaledHeight - scaledMargin),
        greenIndicator  -- Solid green using rgbm
      )
    end
  end


  -- Draw the right half (if active, start ON, then flash)
  if rightActive or hazardActive then
    if flashState then  -- Only draw when flashState is true (ON), but it starts ON
      ui.drawRectFilled(
        vec2(startX + scaledWidth/2 + scaledMargin, startY + scaledMargin),
        vec2(startX + scaledWidth - scaledMargin, startY + scaledHeight - scaledMargin),
        greenIndicator  -- Solid green using rgbm
      )
    end
  end


  -- Draw the center dividing line (always visible, scaled thickness)
  ui.drawLine(
    {startX + scaledWidth/2, startY + scaledMargin},
    {startX + scaledWidth/2, startY + scaledHeight - scaledMargin},
    whiteLine,  -- White line using rgbm
    2 * scale   -- Scale line thickness proportionally
  )


  ui.endOutline()
end

