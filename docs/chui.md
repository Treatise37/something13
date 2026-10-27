# chui — документация

chui — самописный фреймворк окон на HTML для BYOND (Goonstation). Он рисует собственную рамку окна (titlebar, кнопки закрытия/сворачивания, ресайз) поверх `browse()` и даёт DM↔JS взаимодействие.

Файлы:

| Файл | Назначение |
|---|---|
| [code/chui/chui.dm](../code/chui/chui.dm) | Движок `chui/engine`, глобальная переменная `chui`, макросы `CDBG*` |
| [code/chui/window.dm](../code/chui/window.dm) | Класс `chui/window`, `client.Browse()`, verb закрытия, `BrowseHTML()` |
| [code/chui/theme.dm](../code/chui/theme.dm) | Темы: генерация header/body/footer/кнопок |
| [code/chui/template.dm](../code/chui/template.dm) | Шаблоны (недоделаны) |
| [code/chui/cpan.dm](../code/chui/cpan.dm) | Старый `chui/cpan` (выключен `#if 0`) |
| [code/chui/cprof.dm](../code/chui/cprof.dm) | Профайлер-заглушка (только `DEBUG`) |
| [code/chui/example/](../code/chui/example) | Примеры (`chemicals.dm`, `rprules.dm`) |
| [browserassets/js/chui/chui.js](../browserassets/js/chui/chui.js) | Клиентский JS |

## 1. Архитектура

```
chui (global /chui/engine)
 ├─ themes[]        — список экземпляров /chui/theme
 ├─ staticinst      — один общий /chui/window (используется client.Browse)
 └─ GetTheme(name)  — найти тему по имени

/chui/window ── использует ──> /chui/theme ── генерирует HTML ──> клиент (browse)
      ^                                                              |
      └────── Topic() <── ?src=\ref[window]&... <──────── chui.js ───┘
```

Движок создаётся в `world/New()`. `staticinst` создаётся через `spawn(0)`, поэтому до первого тика `client.Browse()` вызывать нельзя.

## 2. Жизненный цикл окна

1. `new /chui/window/моё()` — `New()` превращает строку `theme` в датум темы. Если переопределяете `New()`, вызывайте `..()`.
2. `Subscribe(client)` — добавляет клиента в `subscribers`, вызывает `GetBody()`, оборачивает через `generate()` и открывает окно с именем `\ref[src]` (без рамки BYOND: `titlebar=0;can_close=0;can_resize=0;can_scroll=0;border=0`). Вешает `on-close` → `.chui-close`.
3. Взаимодействие: клики по `a.button` → `Topic()` → `OnClick()`; свои ссылки → `OnTopic()`.
4. `Unsubscribe(client)` — убирает из списка и закрывает окно (`browse(null, ...)`).

Закрытие кнопкой: JS вызывает `.chui-close <ref>` → verb `/client/verb/chuiclose` → `Unsubscribe`. Если окно не chui — просто `browse(null, "window=...")`.

## 3. Переменные `/chui/window`

| Переменная | Тип / по умолчанию | Описание |
|---|---|---|
| `name` | text, `"Untitled Window"` | Заголовок в titlebar. Не обязан быть уникальным |
| `subscribers` | `list/client` | Клиенты с открытым окном. Лучше использовать `IsSubscribed()` |
| `theme` | text `"base"` → `/chui/theme` | Имя темы; в `New()` заменяется на датум |
| `theAtom` | `/atom` | Привязка к объекту: `Validate()` отписывает клиента, если `get_dist(cli.mob.loc, theAtom.loc) > 2` |
| `template` | text / file / `/chui/template` | Готовое тело окна. Файл читается через `file2text`. Движок шаблонов не закончен |
| `sections` | `list`, пусто | Секции — TODO |
| `flags` | `CHUI_FLAG_SIZABLE \| CHUI_FLAG_MOVABLE` | Флаги окна (ниже) |
| `templateVars` | `list` | Значения шаблонных переменных (см. §6) |

### Флаги

| Макрос | Значение | Смысл |
|---|---|---|
| `CHUI_FLAG_SIZABLE` | 1 | Можно менять размер (иначе JS удаляет `div.resizeArea`) |
| `CHUI_FLAG_MOVABLE` | 2 | Можно двигать (в JS сейчас не проверяется) |
| `CHUI_FLAG_FADEIN` | 4 | Плавное появление/исчезновение (~1 c) |

## 4. Процедуры `/chui/window`

| Proc | Описание |
|---|---|
| `GetBody()` | **Переопределяйте.** Возвращает HTML содержимого (без `<html>`/`<head>`) |
| `Subscribe(client)` | Открыть окно клиенту |
| `Unsubscribe(client)` | Закрыть окно клиенту |
| `IsSubscribed(client)` | Подписан ли клиент; заодно вызывает `Validate()` и отписывает невалидных |
| `Validate(client)` | 0 если: клиента нет, не подписан, окно не видимо, слишком далеко от `theAtom` |
| `CallJSFunction(fname, list/args, client/exclude)` | Вызвать JS-функцию у всех подписчиков (через `output()` в `\ref[src].browser`). `exclude` сейчас не используется |
| `SetVar(name, value)` | Задать шаблонную переменную, обновить у клиентов, вызвать `OnVar` |
| `GetVar(name)` | Прочитать шаблонную переменную |
| `template(name, value)` | Вставить в HTML `<span id='chui-tmpl-name'>` с начальным значением |
| `generate(client, body)` | Внутренняя: собирает header+body+footer |
| `bbrowse(client, body, options)` | Внутренняя часть `client.Browse()` |

### Хуки (переопределяются)

| Хук | Когда вызывается |
|---|---|
| `OnTopic(href, href_list)` | Любая ссылка `?src=\ref[window]&...` без `_cact` |
| `OnClick(client, id)` | Нажата кнопка темы (`a.button`), `id` — id кнопки |
| `OnVar(name, value, setFromDM)` | Изменилась шаблонная переменная |
| `OnRequest(method, data)` | Запрос из JS (`chui.request`); не доведено до конца |

> В `Topic()` ветка с неизвестным `_cact` вызывает `OnTopic(usr.client, href, href_list)` — другая сигнатура, чем `OnTopic(href, href_list)`. Для обычных ссылок (без `_cact`) всё работает как описано.

`Topic()` сначала проверяет `IsSubscribed(usr.client)`; неподписанному окно закрывается.

## 5. Темы (`/chui/theme`)

| Элемент | Описание |
|---|---|
| `name` | Имя темы (ищется в `GetTheme`) |
| `generateHeader(params)` | `<!DOCTYPE>`, `<head>`: jQuery, nanoscroller, `chui.js`, `font-awesome.css`, доп. `js`/`css` из `params`, `<title>`, `<meta name=ключ value=значение>` из `params["data"]` (`ref`, `flags`) |
| `generateBody(body, params)` | Рамка окна: titlebar, кнопки, resizeArea, контент в `#content.nano` |
| `generateFooter()` | Закрывающие теги |
| `generateButton(id, label)` | HTML кнопки (`a.button`) — клик приходит в `OnClick` |

`params` — список: `js` (список), `css` (список), `title`, `data` (список meta).

Тема `/chui/theme/base` (имя `"base"`) добавляет `css/chui/themes/default/default.css`. Своя тема:

```dm
chui/theme/mytheme
	name = "mytheme"
	generateHeader(var/list/params)
		params["css"] += list("css/mytheme.css")
		return ..(params)
```

и в окне: `theme = "mytheme"`.

Особенность: `GetTheme` перебирает `i < themes.len` (последняя тема не находится) и при промахе возвращает первую.

## 6. Шаблонные переменные

```dm
GetBody()
	return "Статус: [template("status", "ожидание")]"

// позже, из DM:
SetVar("status", "готово")
```

DM создаёт `<span id='chui-tmpl-status'>`, а `SetVar` вызывает `chui.templateSet("status", "готово")` в JS (меняет `innerText`).

## 7. Два способа показать HTML

| | `client.Browse(html, opts)` | `BrowseHTML(target, html, opts)` |
|---|---|---|
| Рамка chui | да (общий `staticinst`) | нет, обычное окно BYOND |
| `window=` в opts | **обязательно**, иначе `CRASH("No window name given")` | да |
| Поддерживаемые opts | `window`, `size`, `title`, `can_resize` (0/1), `fade_in` (0/1) | все стандартные `browse()` |

`BrowseHTML` (в `window.dm`) — совместимость с BYOND 516: фрагмент HTML без `<html>`-обёртки показывается как текст. Хелпер принимает `/client` или `/mob`, оборачивает фрагмент в полный документ (`browser_html_document()`), а `html = null` закрывает окно. Для обычных окон используйте его вместо `X << browse(...)`.

```dm
usr.client.Browse("<h1>Привет</h1>", "window=hello;size=400x300;title=Hello")
BrowseHTML(usr, "<b>Обычное окно</b>", "window=plain;size=300x200")
```

## 8. JavaScript API (`chui.js`)

| Функция | Описание |
|---|---|
| `chui.window` | ref окна (из `<meta name="ref">`) |
| `chui.flags` | флаги окна |
| `chui.data` | все `<meta>` в виде объекта |
| `chui.bycall(method, data)` | Отправить `?src=<ref>&_cact=method&...` в `Topic()` |
| `chui.close()` | Закрыть окно (`.chui-close`) |
| `chui.winset(key, value)` | `winset` для этого окна |
| `chui.setPos(x, y)`, `chui.setSize(w, h)` | Позиция/размер |
| `chui.fadeIn()`, `chui.fadeOut()` | Анимации |
| `chui.templateSet(id, value)` | Обновить шаблонную переменную |
| `chui.request(path, data, cb)` | Запрос к DM (`_cact=request`); ответ пока не реализован |
| `chui.minWidth/minHeight` | Минимальный размер при ресайзе (200×200) |

Свои JS-функции вызываются из DM через `CallJSFunction("имя", list(арг1, арг2))`. Свои ссылки: `<a href='?src=\ref[src]&action=...'>` в DM-строке.

## 9. Отладка

Макросы `CDBG1/2/3(msg)` работают только при `#define DEBUG` (`CHUI_VERBOSITY` = 2) и пишут в `world`. Без `DEBUG` — пустые.

## 10. Примеры

### Минимальное окно

```dm
chui/window/hello
	name = "Hello"
	GetBody()
		return "<h2>Привет, мир!</h2>"

/client/verb/hello()
	var/chui/window/hello/W = new
	W.Subscribe(src)
```

### Интерактивное окно

```dm
chui/window/counter
	name = "Counter"
	var/n = 0

	GetBody()
		return {"Счётчик: [template("n", n)]<br>
			[theme.generateButton("inc", "+1")]
			<a href='?src=\ref[src]&action=reset'>Сброс</a>"}

	OnClick(client/who, id)
		if(id == "inc")
			n++
			SetVar("n", n)

	OnTopic(href, href_list[])
		if(href_list["action"] == "reset")
			n = 0
			SetVar("n", 0)
```

### Окно, привязанное к объекту

```dm
/obj/machinery/thing
	var/chui/window/counter/ui
	attack_hand(mob/user)
		if(!ui)
			ui = new
			ui.theAtom = src
		ui.Subscribe(user.client)
```

### Вызов JS из DM

```dm
GetBody()
	return {"<div id='log'></div>
		<script>function addLine(t){ $('#log').append('<div>'+t+'</div>'); }</script>"}

// позже
CallJSFunction("addLine", list("новая строка"))
```

Рабочий пример: [chemicals.dm](../code/chui/example/chemicals.dm) (кнопки + `OnClick` + `OnTopic` + `CallJSFunction`).

## 11. Ресурсы

`resource("js/foo.js")` возвращает имя файла из CDN или локальное имя (при `ENV dev` без CDN — просто имя файла). `grabResource("html/x.html")` читает файл из `browserassets/` и подставляет `{{resource("...")}}`. См. [resourceManagement.dm](../code/procs/resourceManagement.dm).

## 12. Известные ограничения

- Движок шаблонов (`chui/template`, bysql) — заглушки; `SetTemplate` бросает исключение.
- `sections`, `generateSwitch` (возвращает `"IDK"`), ответ `chui.request` — не реализованы.
- `CallJSFunction` не использует `exclude`.
- `chui/cpan` отключён (`#if 0`).
- `client.Browse()` использует общий `staticinst`: у такого окна нет `subscribers` и своего `Topic`. Для интерактива создавайте собственное `chui/window`.
- В `bbrowse` `on-close` ставится на `\ref[staticinst]`, а не на указанное окно; закрывайте кнопкой в рамке.
