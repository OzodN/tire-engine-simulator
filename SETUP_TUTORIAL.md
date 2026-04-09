# ПОШАГОВЫЙ ГАЙД: Настройка Roblox Studio для Sprint 1.2

## ШАГИ 1-5: Основная структура (10 минут)

### ШАГ 1: Создать Junkyard папку
```
1. Открыть Workspace в Explorer (View → Explorer)
2. Нажать "+" рядом с Workspace → Folder
3. Переименовать в "Junkyard"
4. Это будет зона, где спавнятся покрышки
```

### ШАГ 2: Создать TireSpawnPoints (5 точек)
```
Для каждой точки спавна:
1. Нажать "+" рядом с Junkyard → Part
2. Переименовать в "TireSpawnPoint"
3. Изменить свойства:
   - Size: 1, 1, 1
   - CanCollide: false (чтобы игрок не запинался)
   - Transparency: 0.5 (чтобы видеть где спавнит)
   - Color: выбрать яркий (например, красный)
4. Расставить 5 штук вокруг Junkyard
   - Position может быть разный
   - Главное - разброс по карте
```

### ШАГ 3: Создать LaunchArea папку
```
1. "+" рядом с Workspace → Folder
2. Переименовать в "LaunchArea"
3. Это зона, где игрок запускает покрышки
```

### ШАГ 4: Создать LaunchPad
```
1. "+" рядом с LaunchArea → Part
2. Переименовать в "LaunchPad"
3. Изменить свойства:
   - Size: 3, 1, 3 (платформа 3×3 studs)
   - Color: выбрать яркий (например, зеленый)
   - Material: Neon (чтобы светилось)
   - Position: где-то высоко над Junkyard (Y = 20-30)
```

### ШАГ 5: Создать Targets папку + Targets
```
1. "+" рядом с Workspace → Folder → "Targets"
2. Внутри создать 3 Part:
   - Переименовать каждый в "Target"
   - Size: 2, 2, 2
   - Color: синий или желтый
   - Расставить на расстоянии 50-100 studs от LaunchPad
   - Позиции могут быть на земле или чуть выше
3. Это будут мишени для попаданий (если попал → бонус ×2)
```

---

## ШАГИ 6-10: UI (15 минут)

### ШАГ 6: Создать MainUI (ScreenGui)
```
1. Открыть StarterGui в Explorer
2. "+" → ScreenGui
3. Переименовать в "MainUI"
4. Изменить свойства MainUI:
   - ResetOnSpawn: false (не исчезает при спауне)
```

### ШАГ 7: Создать CoinsLabel
```
1. "+" рядом с MainUI → TextLabel
2. Переименовать в "CoinsLabel"
3. Изменить свойства:
   - Text: "Coins: 0"
   - Size: X=200, Y=50
   - Position: X=900, Y=10 (правый верхний угол)
   - BackgroundColor3: RGB(50, 50, 50) (серый)
   - TextColor3: RGB(255, 255, 255) (белый)
   - TextSize: 18
   - BorderSizePixel: 0
```

### ШАГ 8: Создать TiresLabel
```
1. "+" рядом с MainUI → TextLabel
2. Переименовать в "TiresLabel"
3. Изменить свойства (как выше):
   - Text: "Tires: 0/5"
   - Position: X=900, Y=70 (под CoinsLabel)
```

### ШАГ 9: Создать UpgradeFrame
```
1. "+" рядом с MainUI → Frame
2. Переименовать в "UpgradeFrame"
3. Изменить свойства:
   - Size: X=300, Y=300
   - Position: X=10, Y=600 (левый нижний угол)
   - BackgroundColor3: RGB(30, 30, 30) (темный)
   - BorderSizePixel: 0
```

### ШАГ 10: Создать Power/Carry UI в UpgradeFrame
```
Для каждого (Power и Carry):

PowerLabel:
1. "+" рядом с UpgradeFrame → TextLabel
2. Name: "PowerLabel"
3. Properties:
   - Text: "Power Lv.1 → 2\n+1 | Cost: 50"
   - Size: FullWidth, Y=60
   - Position: X=0, Y=0
   - BackgroundColor3: RGB(100, 100, 100)
   - TextColor3: white

PowerUp (кнопка):
1. "+" рядом с UpgradeFrame → TextButton
2. Name: "PowerUp"
3. Properties:
   - Text: "BUY"
   - Size: FullWidth, Y=40
   - Position: X=0, Y=70
   - BackgroundColor3: RGB(0, 170, 0) (зеленый)
   - TextColor3: white

CarryLabel & CarryUp:
- Повторить то же самое
- Positions: Y=120 (label), Y=190 (button)
```

---

## ШАГИ 11-15: Финальная настройка (5 минут)

### ШАГ 11: Проверить Services в ServerScriptService
```
Должны быть файлы:
✅ Main.server.lua
✅ Services/ (папка)
  ├── BaseService.lua
  ├── DataService.lua
  ├── LaunchService.lua
  ├── UpgradeService.lua
  ├── PlayerService.lua
  ├── TargetService.lua
  ├── InteractionService.lua
  ├── TireService.lua
  ├── RebirthService.lua
  ├── TireSpawnerService.lua ← НОВЫЙ
  ├── LaunchPadService.lua ← НОВЫЙ
  └── DataSyncService.lua ← НОВЫЙ

Если чего-то нет → скопировать из src/server/Services/
```

### ШАГ 12: Проверить Controllers
```
Должны быть в StarterPlayer > StarterCharacterScripts:
- CameraController.lua
- FXController.lua

Должны быть в StarterPlayer > StarterPlayerScripts:
- LaunchController.client.lua
- UIController.client.lua

Если нет → скопировать из src/client/
```

### ШАГ 13: Проверить Config файлы
```
ReplicatedStorage > Shared > Config:
✅ EconomyConfig.lua ← ОБНОВЛЕН
✅ GameConfig.lua
✅ LaunchConfig.lua
✅ UpgradeConfig.lua
✅ TireConfig.lua ← НОВЫЙ
✅ TireDefinitions.lua ← НОВЫЙ
```

### ШАГ 14: Проверить Types файлы
```
ReplicatedStorage > Shared > Types:
✅ PlayerDataSchema.lua ← ОБНОВЛЕН (новая структура Inventory.Tires)
```

### ШАГ 15: Проверить лоадер
```
ReplicatedStorage > Shared > Modules:
✅ Loader.lua (загружает все Services)
```

---

## ✅ ФИНАЛЬНАЯ ПРОВЕРКА (2 минуты)

Перед запуском тестирования:

```
1. Нажать "Run" чтобы запустить сервер
2. Открыть Output (View → Output)
3. Проверить сообщения:
   ✅ "ProfileService: Roblox API services available"
   ✅ "✅ All services initialized"
   ✅ "✅ Found X spawn points"
   ✅ "🎯 Tire spawner started (max 15 tires)"
   
⚠️ Если есть красные ошибки - проверить пути в коде!
```

---

## 🎮 КАК ТЕСТИРОВАТЬ

1. **Запустить игру** (Start Game в Studio)
2. **Зайти в Junkyard** - должны видеть спавнящиеся покрышки разных цветов
3. **Подобрать покрышку** - включить proximity prompt, нажать E
4. **Проверить UI** - CoinsLabel & TiresLabel обновились
5. **Перейти на LaunchPad** - подойти к зеленой платформе
6. **Запустить покрышку** - покрышка должна улететь ввысь
7. **Проверить траекторию** - Toy летит низко, Spaceship летит высоко

---

## 🚀 ЕСЛИ ЧТО-ТО НЕ РАБОТАЕТ

| Проблема | Решение |
|----------|---------|
| Покрышки не спавнятся | Проверить TireSpawnPoints в Junkyard, их имена |
| UI не обновляется | Проверить UIController.client.lua находится в StarterPlayerScripts |
| Ошибка в консоли про ProfileService | Проверить ServerPackages в ServerScriptService |
| Покрышки не летят | Проверить LaunchPad существует и называется именно "LaunchPad" |
| Кнопки не работают | Проверить размеры TextButton не 0, видны на экране |

---

## 📐 ПРИБЛИЗИТЕЛЬНЫЕ ПОЗИЦИИ (если лень считать)

```lua
-- Junkyard TireSpawnPoints (5 точек, разброс)
1. Position: (0, 2, 0)
2. Position: (30, 2, 0)
3. Position: (-30, 2, 0)
4. Position: (0, 2, 30)
5. Position: (0, 2, -30)

-- LaunchPad
Position: (0, 20, 0)

-- Targets (3 мишени впереди)
1. Position: (0, 2, -50)
2. Position: (-20, 2, -80)
3. Position: (20, 2, -80)
```

Готово! Это займет ~30-40 минут. После этого можно полностью тестировать Sprint 1.2! 🎉
