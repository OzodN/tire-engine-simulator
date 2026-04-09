# 🐛 TROUBLESHOOTING: Если что-то не работает

## ❌ ПРОБЛЕМА 1: "ProfileService module not found"
**Причина:** ServerPackages не скопирована или путь неправильный  
**Решение:**
```
1. Check ServerScriptService > должна быть папка ServerPackages
2. Внутри ServerPackages должен быть ProfileService (Module)
3. Если нет - скопировать вручную:
   - Open Packages/_Index/firebird702_profileservice@1.1.0/profileservice/src/init.lua
   - Copy содержимое
   - Создать в ServerScriptService > ServerPackages > ProfileService > init.lua
   - Вставить код
```

---

## ❌ ПРОБЛЕМА 2: "Junkyard folder not found!" в консоли
**Причина:** Нет папки "Junkyard" в Workspace  
**Решение:**
```
1. Создать Workspace > Folder > назвать "Junkyard"
2. Создать TireSpawnPoints внутри
3. Перезапустить сервер
```

---

## ❌ ПРОБЛЕМА 3: "No TireSpawnPoints found in Junkyard!"
**Причина:** TireSpawnPoints названы неправильно или находятся не в Junkyard  
**Решение:**
```
1. Проверить ВСЕ Parts в Junkyard
2. Убедиться что Name = "TireSpawnPoint" (case-sensitive!)
3. Если Part назван "TireSpawnPoints" (с "S") - ПЕРЕИМЕНОВАТЬ на "TireSpawnPoint"
4. Перезапустить
```

---

## ❌ ПРОБЛЕМА 4: Покрышки спавнятся но их не видно
**Причина:** Junkyard не создана или SpawnPoints не видны  
**Решение:**
```
✅ НОВОЕ: TireSpawnerService теперь автоматически создает Junkyard и SpawnPoint если их нет!

1. При запуске сервера консоль должна показать:
   "⚠️ Junkyard folder not found! Creating it..."
   "✅ Found 1 spawn points"

2. Покрышки спавнятся в видимом месте (0, 5, 0) по умолчанию

3. Если все еще не видно:
   - Открыть Workspace > Junkyard (папка)
   - Проверить TireSpawnPoint существует (Part, Y=5)
   - Нажать F в Studio (focus на объект)
   - Должны видеть спавнящиеся цветные тиры
```

---

## ❌ ПРОБЛЕМА 5: UI элементы не видны на экране
**Причина:** Размеры или позиции установлены неправильно  
**Решение:**
```
Для каждого UI элемента:
1. Выбрать элемент в Explorer
2. Properties > LayoutOrder = 0
3. Проверить:
   - Size.X/Y > 0 и < 1280/720 (в пикселях)
   - Position.X/Y находится на экране (0-1280, 0-720)
   - Visible = true
   - AnchorPoint может быть (0,0) по умолчанию

Если все еще не видно:
   - Установить Position вручную: X=100, Y=100
   - Установить Size вручную: X=200, Y=50
```

---

## ❌ ПРОБЛЕМА 6: Кнопки BUY так и не кликаются
**Причина:** TextButton слишком маленький или скрыт за другим UI  
**Решение:**
```
1. Выбрать PowerUp Button в Explorer
2. Drag его в главное окно viewport
3. Изменить Position так чтобы был видный
4. Drag на нужное место
5. Удалить TextLabel который его перекрывал
```

---

## ❌ ПРОБЛЕМА 7: "LaunchArea folder not found!"
**Причина:** Нет папки "LaunchArea" в Workspace  
**Решение:**
```
1. Создать Workspace > Folder > "LaunchArea"
2. Внутри создать Part > "LaunchPad"
3. Перезапустить
```

---

## ❌ ПРОБЛЕМА 8: Покрышка не летит при запуске
**Причина:** LaunchPad не найден или LaunchController не запущен  
**Решение:**
```
1. Проверить LaunchPad существует и называется ЭТО "LaunchPad"
2. Проверить LaunchArea > LaunchPad (не "LaunchPads"!)
3. Проверить StarterPlayer > StarterPlayerScripts > LaunchController.client.lua
4. F9 (Command Line) выполнить:
   print(game:GetService("Workspace"):FindFirstChild("LaunchArea")) -- не nil?
   print(game:GetService("Workspace").LaunchArea:FindFirstChild("LaunchPad")) -- не nil?
```

---

## ❌ ПРОБЛЕМА 9: "Profile not found for player" в консоли
**Это НОРМАЛЬНО!** Это race condition когда несколько сервисов пытаются Get() до полной загрузки профиля.  
**Можно игнорировать** - профиль загружается, просто может быть delay в 0.5 сек.

---

## ❌ ПРОБЛЕМА 10: CoinsLabel не обновляется
**Причина:** DataSyncService не инициализирован или UIController не слушает события  
**Решение:**
```
1. Проверить Main.server.lua вызывает DataSyncService:Init(services)
2. Проверить UIController.client.lua has:
   dataChangedEvent.OnClientEvent:Connect(function(key, value) ... end)
3. Проверить ReplicatedStorage.Remotes.DataChanged существует
4. F9 execute:
   print(game:GetService("ReplicatedStorage").Remotes:FindFirstChild("DataChanged"))
```

---

## ❌ ПРОБЛЕМА 11: "Attempt to index nil with 'OnClientEvent'"
**Причина:** RemoteEvent DataChanged не создалась автоматически  
**Решение:**
```
1. Открыть ReplicatedStorage > Remotes
2. Если нет DataChanged - создать вручную:
   - "+" > RemoteEvent
   - Name: "DataChanged"
3. Перезапустить сервер
```

---

## ❌ ПРОБЛЕМА 12: Взял покрышку но она не исчезла
**Причина:** InteractionService не инициализирован или Part не назван "Tire"  
**Решение:**
```
1. Проверить Part назван ЭТО "Tire" (case-sensitive)
2. Проверить Part находится в Junkyard
3. Проверить ServerScriptService > Services > InteractionService.lua existе
4. Проверить Main.server.lua инициализирует InteractionService
5. Проверить у Part есть ProximityPrompt (должна создаться автоматически)
```

---

## ❌ ПРОБЛЕМА 13: Ошибка в консоли - "attempt to index nil"
**Это частая проблема!**  
**Решение:**
```
1. Найти строку номер ошибки в консоли (например, "line 42")
2. Открыть файл и найти line 42
3. Проверить что переменная не nil перед использованием:
   if variable then ... end
4. Если переменная должна быть таблицей - проверить что таблица создана
```

Очень полезно: 
```lua
-- Добавить дебаг строку перед ошибкой:
print("DEBUG: variable =", variable, "type:", typeof(variable))
```

---

## ✅ УДАЛЕННЫЕ LEGACY СЕРВИСЫ

Следующие DEPRECATED сервисы были удалены (они не соответствуют нашему плану):
- ❌ **JunkService** - Replaced by TireSpawnerService
- ❌ **PlayerService** - Replaced by DataService
- ❌ **BaseService** - Old tire selling system (replaced by economy formulas)
- ❌ **TireService** - Processing moved to economy formulas

**Текущие активные сервисы:**
- ✅ DataService - Player data & persistence
- ✅ DataSyncService - Real-time UI sync
- ✅ LaunchService - Launch mechanics
- ✅ UpgradeService - Buy Power/Carry
- ✅ TargetService - Hit detection
- ✅ InteractionService - Tire pickup
- ✅ TireSpawnerService - Tire spawning
- ✅ LaunchPadService - Inventory selection
- ✅ RebirthService - Rebirth mechanics

---

1. **Перезапустить Studio полностью:** Close и Open project
2. **Очистить кэш:** File > Clear Output, Delete temp files
3. **Проверить Rojo sync:** 
   - Если используешь Rojo, убедиться что файлы синхронизировались
   - `rojo serve` должна работать без ошибок
4. **Проверить версию Roblox:** Update Studio если есть новая версия
5. **Создать minimal example:**
   - Удалить все лишние элементы
   - Оставить только: Junkyard + TireSpawnPoint, LaunchPad, MainUI
   - Проверить работает ли базовый функционал

---

## 📊 ОТЛАДОЧНАЯ ИНФОРМАЦИЯ

Вставить в Main.server.lua после инициализации всех сервисов:
```lua
-- DEBUG INFO
task.wait(2)
print("\n=== DEBUG CHECK ===")
print("Junkyard:", game.Workspace:FindFirstChild("Junkyard"))
print("LaunchArea:", game.Workspace:FindFirstChild("LaunchArea"))
print("Targets:", game.Workspace:FindFirstChild("Targets"))
print("MainUI:", game.StarterGui:FindFirstChild("MainUI"))
print("DataService loaded:", services.DataService ~= nil)
print("TireSpawnerService loaded:", services.TireSpawnerService ~= nil)
print("=== END DEBUG ===\n")
```

Это выведет ВСЕ основные элементы и поможет найти что не загрузилось.

---

## 🆘 ЕСЛИ НУЖНА ПОМОЩЬ

Скопировать из консоли ВСЕ ошибки и сообщать:
```
1. Полный текст ошибки (все строки)
2. На какой строке и в каком файле
3. Что ты делал когда произошла ошибка (подобрал покрышку? запустил? и т.д)
4. Скриншот Explorer структуры
```

Это поможет быстро найти проблему! 🚀
