﻿Перем КонтекстЯдра;
Перем Утверждения;

#Область ОсновнаяЛогика

Функция СформироватьJSONОстатков(ТестовыйНаборДанных = Ложь)

	Если ТестовыйНаборДанных Тогда
		РезультатЗапроса = ВыполнитьЗапросПолученияТестовыхОстатковДляВыгрузки();
	Иначе
		РезультатЗапроса = ВыполнитьЗапросПолученияОстатковДляВыгрузки();
	КонецЕсли;
	ДанныеПоОстаткам = ОбработатьДанныеПоОстаткам(РезультатЗапроса);
	Возврат СформироватьJSON(ДанныеПоОстаткам);

КонецФункции // СформироватьJSONОстатков()

Функция ОбработатьДанныеПоОстаткам(РезультатЗапроса)
	
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Новый Структура;
	КонецЕсли;
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ВыгрузкаНоменклатуры = Новый Структура;
	Обработано = 1;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		ДанныеПоОстаткам = Новый Структура("id, amount");
		ЗаполнитьЗначенияСвойств(ДанныеПоОстаткам, ВыборкаДетальныеЗаписи);
		
		КлючСтруктуры = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку("nom_%1", Формат(Обработано, "ЧГ="));
		ВыгрузкаНоменклатуры.Вставить(КлючСтруктуры, ДанныеПоОстаткам);
		Обработано = Обработано + 1;
		
	КонецЦикла;
	
	Возврат ВыгрузкаНоменклатуры;

КонецФункции

Функция ВыполнитьЗапросПолученияОстатковДляВыгрузки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СпрНоменклатура.Артикул КАК id,
		|	СпрСклад.гиг_ИдСклада КАК store_id,
		|	СУММА(ВЫБОР
		|			КОГДА СпрНазначения.Ссылка ЕСТЬ НЕ NULL 
		|					И СпрНазначения.Заказ <> НЕОПРЕДЕЛЕНО
		|				ТОГДА 0
		|			КОГДА ИнформацияОДоступности.ДатаПоступления <> ДАТАВРЕМЯ(1, 1, 1)
		|				ТОГДА 0
		|			ИНАЧЕ ИнформацияОДоступности.Свободно
		|		КОНЕЦ) КАК amount
		|ИЗ
		|	РегистрСведений.РаспределениеЗапасов КАК ИнформацияОДоступности
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
		|		ПО ИнформацияОДоступности.Номенклатура = СпрНоменклатура.Ссылка
		|			И (СпрНоменклатура.Артикул <> """")
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Склады КАК СпрСклад
		|		ПО ИнформацияОДоступности.Склад = СпрСклад.Ссылка
		|			И (СпрСклад.гиг_ИдСклада <> """")
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Назначения КАК СпрНазначения
		|		ПО ИнформацияОДоступности.Назначение = СпрНазначения.Ссылка
		|ГДЕ
		|	ИнформацияОДоступности.Свободно <> 0
		|	И СпрНоменклатура.ТипНоменклатуры В (ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Товар), ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.МногооборотнаяТара))
		|
		|СГРУППИРОВАТЬ ПО
		|	СпрСклад.гиг_ИдСклада,
		|	СпрНоменклатура.Артикул
		|
		|ИМЕЮЩИЕ
		|	СУММА(ВЫБОР
		|			КОГДА СпрНазначения.Заказ <> НЕОПРЕДЕЛЕНО
		|				ТОГДА 0
		|			КОГДА ИнформацияОДоступности.ДатаПоступления <> ДАТАВРЕМЯ(1, 1, 1)
		|				ТОГДА 0
		|			ИНАЧЕ ИнформацияОДоступности.Свободно
		|		КОНЕЦ) > 0";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса; 

КонецФункции

Функция ВыполнитьЗапросПолученияТестовыхОстатковДляВыгрузки()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВложенныйЗапрос.id КАК id,
		|	ВложенныйЗапрос.store_id КАК store_id,
		|	ВложенныйЗапрос.amount КАК amount
		|ИЗ
		|	(ВЫБРАТЬ
		|		""11111"" КАК id,
		|		""250"" КАК store_id,
		|		""39"" КАК amount) КАК ВложенныйЗапрос";
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Возврат РезультатЗапроса; 

КонецФункции
 
Функция ТестоваяСтруктураОстатков()
	
	Параметры = Новый Структура;
	Параметры.Вставить("id", "11111");
	Параметры.Вставить("store_id", "250");
	Параметры.Вставить("amount", "39");
	
	ДанныеНом = Новый Структура;
	ДанныеНом.Вставить("nom_1", Параметры);
	
	Возврат ДанныеНом;
	
КонецФункции

// преборазует входящую структуру в JSON
// экранирует не ASCII символы, для отключения поправить параметры записи
//
// ПАРАМЕТРЫ:
// ВходящиеДанные - Структура
//	Ключ - строка
//	Значение - Строка, Число, Дата, Булево, Массив, Структура -
// 		любое серилизуемое в JSON значение
// ФорматироватьJSON - БУЛЕВО - если нужно сформировать JSON для вывода в форматированном виде
//
// Возвращаемое значение:
// 	Строка - сформированный JSON
//
Функция СформироватьJSON(ВходящиеДанные, ФорматироватьJSON = Ложь)
	
	Если ФорматироватьJSON Тогда
		СимволФорматирования = Символы.Таб;
	Иначе
		СимволФорматирования = Неопределено;	
	КонецЕсли;
	
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(,СимволФорматирования,, ЭкранированиеСимволовJSON.СимволыВнеASCII);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.ПроверятьСтруктуру = Ложь;
	ЗаписьJSON.УстановитьСтроку(ПараметрыЗаписиJSON);
	ЗаписатьJSON(ЗаписьJSON, ВходящиеДанные);
	
	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции // СформироватьJSON()

#КонецОбласти

#Область TDD

//{ основная процедура для юнит-тестирования xUnitFor1C
Процедура Инициализация(КонтекстЯдраПараметр) Экспорт
	КонтекстЯдра = КонтекстЯдраПараметр;
	Утверждения = КонтекстЯдра.Плагин("БазовыеУтверждения");
КонецПроцедуры

Процедура ЗаполнитьНаборТестов(НаборТестов, КонтекстЯдраПараметр) Экспорт
	
	КонтекстЯдра = КонтекстЯдраПараметр;
  
  НаборТестов.НачатьГруппу("ВыгрузкаОстатков");
  НаборТестов.Добавить("ТестДолжен_ПолучитьJSON_Остатки");
  НаборТестов.Добавить("ТестДолжен_ПроверитьНаличиеРеальныхДанныхВБазе_Остатки");
  НаборТестов.Добавить("ТестДолжен_СравнитьФормированиеТестовогоНабораJSON_Остатки");
 
КонецПроцедуры

//}

//{ Блок юнит-тестов

Процедура ПередЗапускомТеста() Экспорт
	НачатьТранзакцию();
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	Если ТранзакцияАктивна() Тогда
	    ОтменитьТранзакцию();
	КонецЕсли;
КонецПроцедуры

Процедура ТестДолжен_ПолучитьJSON_Остатки() Экспорт
	
	Данные = СформироватьJSONОстатков();
	
	Утверждения.ПроверитьНеРавенство(Данные, Неопределено);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьНаличиеРеальныхДанныхВБазе_Остатки() Экспорт
	
	РезультатЗапроса = ВыполнитьЗапросПолученияОстатковДляВыгрузки();
	
	Утверждения.ПроверитьЛожь(РезультатЗапроса.Пустой());
	
КонецПроцедуры

Процедура ТестДолжен_СравнитьФормированиеТестовогоНабораJSON_Остатки() Экспорт
	
	Данные = СформироватьJSONОстатков(Истина);
	ДанныеЭталон = СформироватьJSON(ТестоваяСтруктураОстатков());
	
	Утверждения.ПроверитьРавенство(Данные, ДанныеЭталон, "Не удалось корректно сформировать JSON с тестовыми остатками");
	
КонецПроцедуры

//} 

#КонецОбласти
