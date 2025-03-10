wait(5) -- nolur nolmaz diye bi 5 saniye bekliyo oyun yuklenen kadar

-- animasyon bide ses, yarin kamera offset degisme yaz ki daha guzel dursun
local KeyCode = Enum.KeyCode.E
local HoverAnimID = "rbxassetid://1231" -- hover animasyonu yapamdim o yuzden random biseler yazddim
local FlyAnimID = "rbxassetid://116833886532685"
local BackwardsFlyAnimID = "rbxassetid://131997306394808"
local WindSoundEnabled = true

-- BodyGyro ve BodyVelocity karakterin hareketiyle ilgili seyler iste kodun icinde ondan var onu kopyaliyo
local BodyVelocity = script:WaitForChild("BodyVelocity"):Clone()
local BodyGyro = script.BodyGyro:Clone()
local Player = game:GetService("Players").LocalPlayer -- oyuncuya erisim normalde Script yada diger adiyla ServerScript kullanirsan oyuncuya erisemezsin ama local scriptler replicated yani cogaltildigi icin erisebiliyosun
local Character = Player.Character
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid") -- Humanoid karakterin icinde olur ve onun bir canli oldugunu belirtir Health MaxHealt WalkSpeed JumpPower gibi ozellikleri var CameraOffset de bunlardan biri 
local Camera = game.Workspace.Camera

-- Animasyonlar ve ses
local HoverAnimation = script:WaitForChild("Animations"):WaitForChild("Hover")
HoverAnimation.AnimationId = HoverAnimID
local FlyAnimation = script:WaitForChild("Animations"):WaitForChild("Fly")
FlyAnimation.AnimationId = FlyAnimID
local BackwardsFlyAnimation = script:WaitForChild("Animations"):WaitForChild("BackwardsFly")
BackwardsFlyAnimation.AnimationId = BackwardsFlyAnimID

local Sound1 = Instance.new("Sound", Character.HumanoidRootPart)
Sound1.SoundId = "rbxassetid://3308152153"
Sound1.Name = "WindSound"

--sesi degistirme
if not WindSoundEnabled then
	Sound1.Volume = 0
end

local HoverAnim = Humanoid.Animator:LoadAnimation(HoverAnimation)
local FlyAnim = Humanoid.Animator:LoadAnimation(FlyAnimation)
local BackwardsFlyAnim = Humanoid.Animator:LoadAnimation(BackwardsFlyAnimation)

-- degiskelner fln
local IsFlying = false
local Flymoving = script.Flymoving
local TweenService = game:GetService("TweenService") -- bir seyleri yumusak gecis ile yapmana izin veriyo mesela direk olacagina senin verdigin bir aralikta oluyo mesela TweenInfo su TweenInfo.new(1) olursa bir saniye icinde o seyi smooth bi sekilde yapiyo

-- bu ikiseyin arasindaki hersey comment olarak sayilir

--[[
tween service i daha iyi anlaman icin ornek

local TS = game:GetService("TweenService") -- import gibi ama import degil normal lua da yok roblox studio ya ozel bisey normalde require() var o luanin importu onla Modul cagiriyon ama bu kodlarda otomatik olan bisey

local block = Instance.new("Part", game.Workspace) -- yeni bir blok olusturuyo ve Parentini yani bulundugu seyi Workspace yani map flnin oldugu yere atiyo

block.Anchored = true -- yere dusmeyip yerinde sabit durmasi roblox ta yer cekimi var ya

block.Position = Vector3.new(0, 0, 0) -- x, y ,z si 0 Vector 3 3 tane vektorden olusan birim mesela bide Vector2 var onda sadece x ve y var o da ekran ve UI icindir ama roblox genllikle Udim2 kullanir UI ler icin

local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear) -- time, easingstyle , easing direction , repeat count, reverses, delaytime sirasinda ben genellikle sadece time ile ile easingstyle i kullanirim

local Tween = TS:Create(Part, TweenInfo, {Color = Color3.new(1, 1, 1)}) -- instance yani hangi objeye, tweenbilgisi bide nasil bir islem gerceklesecegi normalde bi table ye yazmasan senden bir degisken bekler ama {} yani table icine yazarsan bir attribute ayzacagini bilir bu ornekte siyaha ceviriyo blogu

Tween:Play() -- tweeni oynatiyo

Tween.Completed:Wait() -- tween bitene kadar bekle

print("Tween Bitti!") 
--]]


local UIS = game:GetService("UserInputService") -- Input servisi iste keyboard var mouse var ekrana dokunma var

local Speed = 0 --bastaki hiz
local DefaultMaxSpeed = 100 --normal maksimum hiz
local MaxSpeed = 100 --maksimum hiz
local BaseAcceleration = 5  -- ne kadar hizli basta
local IncreasedAcceleration = 15  -- sonradan degisiyo daha guzel dursun die
local Deceleration = 5  -- buda azalmasi
local StartAccelerationTime = 2  -- buda kac sn sonra daha hizli hizlanmaya gececegi
local TimeFlying = 0  -- kac saniyedir uctugun glb sildim sonradan artik kullanilmiyo ama oyle dursun diye

local rotationSpeed = 0.01  -- donme hizi

local currentAcceleration -- bu degiskenin basta hernangi bir degeri yok sonradan degisiyo sadece kodun heryerinden ulasilabilsin diye basta local lestiryo cunku ornek olarak if kondisyon then birseyleryap end then ile end arasinda bir variable yazarsan end den sonraki yada then den onceki satirlarda o variableye ulasamazsin 

--basta kullanip sonradan vazgectigim biseler iste commentledim sIk sIk yaptm bole seyler yanlis anlama diye I kullandim i yerine benim keyboardda turkce karakterler yok
--[[
local StartAccelerationTimePassed = false

local DecelerationFovTween = TweenService:Create(Camera, TweenInfo.new(1), {FieldOfView = 70})
local DecelerationFovTweenPlaying = false
--]]

local player = game.Players.LocalPlayer -- oyuncuyu 2 kere yazmisim qweqweqwe bosver 
local mouse = player:GetMouse()
local userInputService = game:GetService("UserInputService") -- bunuda daha once UIS diye yazmistim

-- Varsayılan kamera offset (normal durumda)
local defaultOffset = Vector3.new(0, 0, 0)

-- Kamera hareket yönü
local offset = defaultOffset

-- boyle fonksiyonlar var bunlarin neye yaradigini merak edersen sor

local function getMouseDirection()
	local delta = userInputService:GetMouseDelta()
	if delta.X > 0 then
		return "Right"
	elseif delta.X < 0 then
		return "Left"
	end

	if delta.Y > 0 then
		return "Up"
	elseif delta.Y < 0 then
		return "Down"
	else
		return nil
	end
end

-- Movement Directionu hesaplama
local function getMovementDirection()
	local direction = Vector3.new()
	
	if UIS:IsKeyDown(Enum.KeyCode.W) then
		direction = Camera.CFrame.lookVector
		
		BackwardsFlyAnim:Stop()
		
		if not FlyAnim.IsPlaying then
			FlyAnim:Play()
			MaxSpeed = DefaultMaxSpeed
		end
	elseif UIS:IsKeyDown(Enum.KeyCode.S) then
		direction = -Camera.CFrame.lookVector
		
		FlyAnim:Stop()
		
		if not BackwardsFlyAnim.IsPlaying then
			BackwardsFlyAnim:Play()
			MaxSpeed = 40
		end
	end
	
	local MouseDirection = getMouseDirection()
	
	----- yanlislikla yazdim bunu
	--if MouseDirection == "Left" then
	--	Camera.CFrame = Camera.CFrame * CFrame.Angles(0, rotationSpeed, 0)
	--	Character:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.Angles(0, rotationSpeed, 0))
		
	--elseif MouseDirection == "Right" then
	--	Camera.CFrame = Camera.CFrame * CFrame.Angles(0, -rotationSpeed, 0)
	--	Character:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.Angles(0, -rotationSpeed, 0))

	--end

	---- A ve D ile donme olmasin dedim bilmiom daha guzel duruyo kullanmiyom ama artik
	--if UIS:IsKeyDown(Enum.KeyCode.A) then
	--	-- kamera sola donme
	--	Camera.CFrame = Camera.CFrame * CFrame.Angles(0, rotationSpeed, 0)
	--	-- oyuncu sola donme
	--	Character:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.Angles(0, rotationSpeed, 0))
	--elseif UIS:IsKeyDown(Enum.KeyCode.D) then
	--	-- kamera saga donme
	--	Camera.CFrame = Camera.CFrame * CFrame.Angles(0, -rotationSpeed, 0)
	--	-- oyuncu saga donme
	--	Character:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.Angles(0, -rotationSpeed, 0))
	--end

	return direction
end


-- ucma fonksiyonlari task.spawn kullandimki kodun devaminin calismasini engellemesin engelliyomu hic bilmiom ama nolur nolmaz

task.spawn(function()
	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
		if Humanoid.MoveDirection == Vector3.new(0, 0, 0)  then
			Speed = 0
			currentAcceleration = BaseAcceleration
			
			--if not DecelerationFovTweenPlaying then
			--	DecelerationFovTween:Play()
			--	DecelerationFovTweenPlaying = true
				
			--	DecelerationFovTween.Completed:Connect(function()
			--		DecelerationFovTweenPlaying = false
			--	end)
			--end
		end
	end)
end)

task.spawn(function()
	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
		
		if script.Parent == Character then
			if IsFlying then
				Humanoid:ChangeState(6)  -- oyuncunun durumunu degistiriyoki baska animasyonlar oynamasin yurume vb
				BodyGyro.CFrame = game.Workspace.Camera.CFrame

				local moveDirection = getMovementDirection()

				-- accelerationun degismesi
				TimeFlying = TimeFlying + deltaTime

				-- normale ceviriyoa basta
				currentAcceleration = BaseAcceleration
				
				if StartAccelerationTimePassed then
					currentAcceleration = IncreasedAcceleration
				end
				
				
				--if TimeFlying > StartAccelerationTime then
				--	-- Increase acceleration after the initial time period
				--	currentAcceleration = IncreasedAcceleration
				--end

				-- hizlanmak yada yavaslamak 
				
				if moveDirection.Magnitude > 0 then
					Flymoving.Value = true
					
					Speed = math.min(Speed + currentAcceleration * deltaTime, MaxSpeed) -- hizlanma
				else
					Flymoving.Value = false
					Speed = math.max(Speed - Deceleration * deltaTime, 0) -- yavaslama
				end

				TweenService:Create(BodyVelocity, TweenInfo.new(0.3), {Velocity = moveDirection * Speed}):Play()
			end
		end
	end)
end)

--------------------------------------------------------------------------------

local function updateCameraOffset()
	offset = defaultOffset
	
	print(getMouseDirection())

	if userInputService:IsKeyDown(Enum.KeyCode.W) then
		offset = offset + Vector3.new(0, 0, -5)  -- İleri
	end
	
	if userInputService:IsKeyDown(Enum.KeyCode.S) then
		offset = offset + Vector3.new(0, 0, 5)   -- Geri
	end
	
	if getMouseDirection() == "Left" then
		offset = offset + Vector3.new(-9, 0, 0)  -- Sola
	end
	
	if getMouseDirection() == "Right" then
		offset = offset + Vector3.new(9, 0, 0)   -- Sağa
	end

	-- Easing için gerekli ayarlar
	local tweenInfo = TweenInfo.new(
		Speed * 0.02, -- Süre
		Enum.EasingStyle.Linear, -- Easing tarzı
		Enum.EasingDirection.InOut, -- Easing yönü
		0, -- Tekrar sayısı
		false -- Geri dönüşümlü değil
	)

	-- Tween ile camera offset uygulamak
	local tween = TweenService:Create(Humanoid, tweenInfo, {CameraOffset = offset})
	tween:Play()
end

task.spawn(function()
	game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
		local KeysPressed = userInputService:GetKeysPressed()

		local WASDpressed = false

		for i, key in pairs(KeysPressed) do

			if WASDpressed == true then
				continue
			end

			if key then
				if key:IsA("InputObject") then
					if key.KeyCode == Enum.KeyCode.W then
						WASDpressed = true

					elseif key.KeyCode == Enum.KeyCode.S then
						WASDpressed = true

					elseif getMouseDirection() == "Right" then
						WASDpressed = true

					elseif getMouseDirection() == "Left" then
						WASDpressed = true
					end
				end
			end
		end

		if WASDpressed == false then
			local DefaultTween = TweenService:Create(Humanoid, TweenInfo.new(1), {CameraOffset = defaultOffset})

			DefaultTween:Play()
		end
	end)
end)


-- RenderStepped'te sürekli olarak kamera yönünü güncelle
game:GetService("RunService").RenderStepped:Connect(function()
	if script:WaitForChild("Flymoving").Value == false then return end

	updateCameraOffset()
end)

-------------------------------------------------------------------------------


-- estetik seyler daha cok fov animasyon ses vb
Flymoving.Changed:Connect(function(isMoving)
	if isMoving then
		TweenService:Create(Camera, TweenInfo.new(8), {FieldOfView = 100}):Play()
		HoverAnim:Stop()
		Sound1:Play()
		FlyAnim:Play()
	else
		TweenService:Create(Camera, TweenInfo.new(2), {FieldOfView = 70}):Play()
		FlyAnim:Stop()
		BackwardsFlyAnim:Stop()
		Sound1:Stop()
		HoverAnim:Play()
		
		currentAcceleration = BaseAcceleration
	end
end)

-- ucma
UIS.InputBegan:Connect(function(key, gameProcessed)
	if gameProcessed then return end

	if key.KeyCode == KeyCode then
		if not IsFlying then
			-- Start flying
			Humanoid.AutoRotate = false
			IsFlying = true
			TimeFlying = 0  -- zamani sifirlama
			
			if Character:FindFirstChild("HumanoidRootPart") then
				HoverAnim:Play(0.1, 1, 1)
				-- kosmasina fln izin vermeme
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
				-- kosma sesi cikmasin
				Character.HumanoidRootPart.Running.Volume = 0
				Humanoid:ChangeState(6)
				-- velocity ve gyroyu karaktere atma
				BodyVelocity.Parent = Character.HumanoidRootPart
				BodyGyro.Parent = Character.HumanoidRootPart
				
				task.wait(StartAccelerationTime)
				
				if IsFlying then
					StartAccelerationTimePassed = true
					currentAcceleration = IncreasedAcceleration
				end
			end
		else
			-- ucmayi durdurma
			Humanoid.AutoRotate = true
			IsFlying = false
			Flymoving.Value = false
			-- geri kosmaya fln izin verme
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
			-- geri kosma sesi
			Character.HumanoidRootPart.Running.Volume = 0.65
			Humanoid:ChangeState(8)
			-- velolari karaktere atma
			BodyVelocity.Parent = Character
			BodyGyro.Parent = Character
			HoverAnim:Stop()
			FlyAnim:Stop()
			BackwardsFlyAnim:Stop()
			StartAccelerationTimePassed = false
			currentAcceleration = BaseAcceleration
			Speed = 0
			
			print(StartAccelerationTimePassed)
		end
	end
end)
