--- === CMatrixScreensaver ===
---
--- A screensaver that launches cmatrix in fullscreen terminal after idle timeout
---
--- Download: N/A (Custom Spoon)
---

local obj = {}
obj.__index = obj

-- Metadata
obj.name = "CMatrixScreensaver"
obj.version = "1.0"
obj.author = "Custom"
obj.homepage = "N/A"
obj.license = "MIT"

--- CMatrixScreensaver.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('CMatrixScreensaver')

--- CMatrixScreensaver.idleTimeout
--- Variable
--- Idle timeout in seconds before screensaver activates (default: 900 = 15 minutes)
obj.idleTimeout = 900

--- CMatrixScreensaver.terminal
--- Variable
--- Terminal application to use (default: "Alacritty")
obj.terminal = "Alacritty"

--- CMatrixScreensaver.cmatrixArgs
--- Variable
--- Additional arguments to pass to cmatrix (default: "")
obj.cmatrixArgs = ""

-- Internal variables
obj.idleTimer = nil
obj.screensaverWindow = nil
obj.isActive = false

--- CMatrixScreensaver:init()
--- Method
--- Initialize the spoon
function obj:init()
    self.logger.i("Initializing CMatrixScreensaver")
    return self
end

--- CMatrixScreensaver:checkIdleTime()
--- Method
--- Check if system has been idle long enough to trigger screensaver
function obj:checkIdleTime()
    if self.isActive then
        return
    end

    local idleTime = hs.host.idleTime()

    if idleTime >= self.idleTimeout then
        self.logger.i(string.format("Idle timeout reached (%.0f seconds), activating screensaver", idleTime))
        self:activateScreensaver()
    end
end

--- CMatrixScreensaver:activateScreensaver()
--- Method
--- Activate the cmatrix screensaver
function obj:activateScreensaver()
    self.logger.i("Activating cmatrix screensaver")

    self.isActive = true

    -- Build cmatrix command with args
    local cmatrixCmd = "cmatrix"
    if self.cmatrixArgs ~= "" then
        cmatrixCmd = cmatrixCmd .. " " .. self.cmatrixArgs
    end

    -- Hardcode the cmatrix path since hs.execute doesn't have proper PATH
    local cmatrixPath = "/opt/homebrew/bin/cmatrix"

    -- Add any additional args
    if self.cmatrixArgs ~= "" then
        cmatrixPath = cmatrixPath .. " " .. self.cmatrixArgs
    end

    self.logger.i("Using cmatrix command: " .. cmatrixPath)

    -- Create a wrapper script to keep the terminal alive
    local wrapperScript = string.format([[#!/bin/zsh
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
%s
exec /bin/zsh
]], cmatrixPath)

    -- Write wrapper to a temp file
    local tmpFile = "/tmp/cmatrix_wrapper.sh"
    local file = io.open(tmpFile, "w")
    file:write(wrapperScript)
    file:close()
    os.execute(string.format("chmod +x %s", tmpFile))

    -- Launch Alacritty with the wrapper script
    os.execute(string.format("open -n -a Alacritty --args -e %s &", tmpFile))

    -- Wait for Alacritty window to appear, bring to front, and go fullscreen
    hs.timer.doAfter(0.8, function()
        local alacritty = hs.application.find("Alacritty")
        if alacritty then
            -- Activate Alacritty to bring it to front
            alacritty:activate()

            local windows = alacritty:allWindows()
            if #windows > 0 then
                -- Get the newest window (last in list)
                local newWindow = windows[#windows]
                self.screensaverWindow = newWindow

                -- Focus and raise the window
                newWindow:focus()
                newWindow:raise()

                -- Wait a bit more then make it fullscreen
                hs.timer.doAfter(0.5, function()
                    if self.screensaverWindow then
                        self.screensaverWindow:setFullScreen(true)

                        -- Watch for window destruction (in case user closes manually)
                        self.screensaverWindow:setCallback(function(win, event)
                            if event == "destroyed" and self.isActive then
                                self.logger.i("Window closed manually - cleaning up")
                                self.isActive = false
                            end
                        end)
                    end
                end)
            end
        end
    end)
end

--- CMatrixScreensaver:start()
--- Method
--- Start the idle monitoring
function obj:start()
    self.logger.i(string.format("Starting CMatrixScreensaver (idle timeout: %d seconds)", self.idleTimeout))

    -- Check idle time every 30 seconds
    self.idleTimer = hs.timer.doEvery(30, function()
        self:checkIdleTime()
    end)

    return self
end

--- CMatrixScreensaver:stop()
--- Method
--- Stop the idle monitoring
function obj:stop()
    self.logger.i("Stopping CMatrixScreensaver")

    if self.idleTimer then
        self.idleTimer:stop()
        self.idleTimer = nil
    end

    self.isActive = false

    return self
end

--- CMatrixScreensaver:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for CMatrixScreensaver
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * trigger - manually trigger the screensaver
function obj:bindHotkeys(mapping)
    local def = {
        trigger = hs.fnutils.partial(self.activateScreensaver, self)
    }
    hs.spoons.bindHotkeysToSpec(def, mapping)

    return self
end

return obj
