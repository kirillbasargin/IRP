Function GetDefaultSettings(EquipmentType) Export
	Settings = New Structure;
	If EquipmentType = PredefinedValue("Enum.EquipmentTypes.InputDevice") Then
		Settings.Insert("ComEncoding", "UTF-8");
		Settings.Insert("DataBits", 8);
		Settings.Insert("GSSymbolKey", -1);
		Settings.Insert("IgnoreKeyboardState", True);
		Settings.Insert("OutputDataType", 0);
		Settings.Insert("Port", 3);
		Settings.Insert("Prefix", -1);
		Settings.Insert("Speed", 9600);
		Settings.Insert("StopBit", 0);
		Settings.Insert("Suffix", 13);
		Settings.Insert("Timeout", 75);
		Settings.Insert("TimeoutCOM", 5);
	EndIf;
	Return Settings;
EndFunction

Процедура BeginGetDriver(ОповещениеПриЗавершении, ДанныеДрайвера) Экспорт
	
	ОбъектДрайвера = Неопределено;
	
	
	Для Каждого ДрайверПО Из globalEquipments.Drivers Цикл
		Если ДрайверПО.Ключ = ДанныеДрайвера.Driver  Тогда
			ОбъектДрайвера = ДрайверПО.Значение;
			ВыполнитьОбработкуОповещения(ОповещениеПриЗавершении, ОбъектДрайвера);
			Возврат;
		КонецЕсли;
	КонецЦикла;
		
	Если ОбъектДрайвера = Неопределено Тогда
			ProgID = ДанныеДрайвера.AddInID;
			Если ПустаяСтрока(ProgID) Тогда
				ОбъектДрайвера = ""; // Драйвер не требуется
				ВыполнитьОбработкуОповещения(ОповещениеПриЗавершении, ОбъектДрайвера);
			Иначе
				ProgID1 = ?(Найти(ProgID, "|") > 0, Сред(ProgID, 1, Найти(ProgID, "|")-1), ProgID); 
				ProgID2 = ?(Найти(ProgID, "|") > 0, Сред(ProgID, Найти(ProgID, "|")+1), ProgID); 
				

					ИмяОбъекта = Сред(ProgID1, Найти(ProgID1, ".") + 1); 
					Префикс = Сред(ProgID1, 1, Найти(ProgID1, ".")); 
					ProgID2 = Префикс + СтрЗаменить(ИмяОбъекта, ".", "_") + "." + ИмяОбъекта;
					
					Параметры = Новый Структура("ProgID, ОповещениеПриЗавершении, ДрайверОборудования", ProgID2, ОповещениеПриЗавершении, ДанныеДрайвера.Driver);
					Оповещение = Новый ОписаниеОповещения("НачатьПолучениеОбъектаДрайвераЗавершение", ЭтотОбъект, Параметры);

					СсылкаНаДрайвер = ПолучитьНавигационнуюСсылку(ДанныеДрайвера.Driver, "Driver");
					BeginAttachingAddIn(Оповещение, СсылкаНаДрайвер, СтрЗаменить(ИмяОбъекта, ".", "_"));


			КонецЕсли;
	КонецЕсли;   
	
КонецПроцедуры

Процедура НачатьПолучениеОбъектаДрайвераЗавершение(Подключено, ДополнительныеПараметры) Экспорт
	
	ОбъектДрайвера = Неопределено;
	
	Если Подключено Тогда 
		Попытка
			ОбъектДрайвера = Новый (ДополнительныеПараметры.ProgID);
			Если ОбъектДрайвера <> Неопределено Тогда
				globalEquipments.Drivers.Вставить(ДополнительныеПараметры.ДрайверОборудования, ОбъектДрайвера);
				ОбъектДрайвера = globalEquipments.Drivers[ДополнительныеПараметры.ДрайверОборудования];
			КонецЕсли;
			ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповещениеПриЗавершении, ОбъектДрайвера);
			Возврат;
		Исключение
			ОбъектДрайвера = Неопределено;
		КонецПопытки;
	КонецЕсли;
	
	ВыполнитьОбработкуОповещения(ДополнительныеПараметры.ОповещениеПриЗавершении, Неопределено);
	
КонецПроцедуры

Процедура InstallDriver(Идентификатор, ОповещениеИзАрхиваПриЗавершении = Неопределено) Экспорт
	
	ДанныеДрайвера = HardwareServer.GetDriverSettings(Идентификатор);
	

	СсылкаНаДрайвер = ПолучитьНавигационнуюСсылку(ДанныеДрайвера.EquipmentDriver, "Driver");
	НачатьУстановкуВнешнейКомпоненты(ОповещениеИзАрхиваПриЗавершении, СсылкаНаДрайвер);

КонецПроцедуры

////////////////////////////////////////////////////////

Процедура НачатьВыполнениеДополнительнойКоманды(ОповещениеПриЗавершении, Команда, ВходныеПараметры, Идентификатор, Параметры) Экспорт
	
	// Поиск подключенного устройства.
	ПодключенноеУстройство = ПолучитьПодключенноеУстройство(globalEquipments.ConnectionSettings, Идентификатор);
	                                                       
	Если ПодключенноеУстройство = Неопределено Тогда
		ДанныеОборудования = HardwareServer.GetConnectionSettings(Идентификатор);
		ПараметрыКоманды = Новый Структура();
		ПараметрыКоманды.Вставить("Команда"           , Команда);
		ПараметрыКоманды.Вставить("ВходныеПараметры"  , ВходныеПараметры);
		ПараметрыКоманды.Вставить("Параметры"         , Параметры);
		ПараметрыКоманды.Вставить("ДанныеОборудования", ДанныеОборудования);
		ПараметрыКоманды.Вставить("ОповещениеПриЗавершении", ОповещениеПриЗавершении);
		Оповещение = Новый ОписаниеОповещения("НачатьВыполнениеДополнительнойКоманды_Завершение", ЭтотОбъект, ПараметрыКоманды);
		BeginGetDriver(Оповещение, ДанныеОборудования);
	Иначе
		// Сообщить об ошибке, что устройство подключено.
		ТекстОшибки = НСтр("ru='Устройство подключено. Перед выполнением операции устройство должно быть отключено.'");
		ВыходныеПараметры = Новый Массив();
		ВыходныеПараметры.Добавить(999);
		ВыходныеПараметры.Добавить(ТекстОшибки);
		ВыходныеПараметры.Добавить(НСтр("ru='Установлен'"));
		РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Ложь, ТекстОшибки, Идентификатор); 
		РезультатВыполнения.ВыходныеПараметры = ВыходныеПараметры;
		ВыполнитьОбработкуОповещения(ОповещениеПриЗавершении, РезультатВыполнения);
	КонецЕсли;
	
КонецПроцедуры

Функция ПараметрыВыполненияОперацииНаОборудовании(Результат = Ложь, ОписаниеОшибки = Неопределено, ИдентификаторУстройства = Неопределено) Экспорт; 
	
	РезультатВыполнения = Новый Структура();
	РезультатВыполнения.Вставить("Result"              , Результат);
	РезультатВыполнения.Вставить("ОписаниеОшибки"         , ОписаниеОшибки);
	РезультатВыполнения.Вставить("ИдентификаторУстройства", ИдентификаторУстройства);
	РезультатВыполнения.Вставить("ВыходныеПараметры"      , Неопределено);
	Возврат РезультатВыполнения;
	
КонецФункции

Функция ПолучитьПодключенноеУстройство(СписокПодключений, Идентификатор) Экспорт
	
	ПодключенноеУстройство = Неопределено;
	
	Для Каждого Подключение Из СписокПодключений Цикл
		Если Подключение.Ссылка = Идентификатор Тогда
			ПодключенноеУстройство = Подключение;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ПодключенноеУстройство;
	
КонецФункции

Процедура НачатьВыполнениеДополнительнойКоманды_Завершение(ОбъектДрайвера, ПараметрыКоманды) Экспорт
	
	Если ОбъектДрайвера = Неопределено Тогда
		// Сообщить об ошибке, что не удалось загрузить драйвер.
		ТекстОшибки = НСтр("ru='Не удалось загрузить драйвер устройства.
								|Проверьте, что драйвер корректно установлен и зарегистрирован в системе.'");
		ВыходныеПараметры = Новый Массив();
		ВыходныеПараметры.Добавить(999);
		ВыходныеПараметры.Добавить(ТекстОшибки);
		ВыходныеПараметры.Добавить(НСтр("ru='Не установлен'"));
		РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Ложь, ТекстОшибки); 
		РезультатВыполнения.ВыходныеПараметры = ВыходныеПараметры;
		ВыполнитьОбработкуОповещения(ПараметрыКоманды.ОповещениеПриЗавершении, РезультатВыполнения);
	Иначе
		
		ДанныеОборудования = ПараметрыКоманды.ДанныеОборудования; 
		ОбработчикДрайвераМодуль = ПолучитьОбработчикДрайвера(ДанныеОборудования.EquipmentType);
		
		Если ОбработчикДрайвераМодуль = Неопределено Тогда
			// Сообщить об ошибке, что не удалось подключить обработчик драйвера.
			ТекстОшибки = НСтр("en='Can`t connect proccesing module'");
			ВыходныеПараметры = Новый Массив();
			ВыходныеПараметры.Добавить(999);
			ВыходныеПараметры.Добавить(ТекстОшибки);
			ВыходныеПараметры.Добавить(НСтр("en='Not installed'"));
			РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Ложь, ТекстОшибки); 
			РезультатВыполнения.ВыходныеПараметры = ВыходныеПараметры;
			ВыполнитьОбработкуОповещения(ПараметрыКоманды.ОповещениеПриЗавершении, РезультатВыполнения);
		Иначе
			времПараметрыПодключения = Новый Структура();
			времПараметрыПодключения.Вставить("EquipmentType", "СканерШтрихкода");
			
			ТекстОшибки = "";
			ВыходныеПараметры = Неопределено;
			Результат = ОбработчикДрайвераМодуль.ВыполнитьКоманду(ПараметрыКоманды.Команда, ПараметрыКоманды.ВходныеПараметры,
				ВыходныеПараметры, ОбъектДрайвера, ПараметрыКоманды.Параметры, времПараметрыПодключения);
			Если Не Результат Тогда
				Если ВыходныеПараметры.Количество() >= 2 Тогда
					ТекстОшибки = ВыходныеПараметры[1];
				КонецЕсли;
				ВыходныеПараметры.Добавить(НСтр("en='Installed'"));
			КонецЕсли;
			РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Результат); 
			РезультатВыполнения.ВыходныеПараметры = ВыходныеПараметры;
			ВыполнитьОбработкуОповещения(ПараметрыКоманды.ОповещениеПриЗавершении, РезультатВыполнения);

			
		КонецЕсли
	КонецЕсли;
	
КонецПроцедуры

Function ПолучитьОбработчикДрайвера(EquipmentType)
	If EquipmentType = PredefinedValue("Enum.EquipmentTypes.InputDevice") Then
		Return HardwareInputDevice;
	EndIf;
EndFunction

///////////////////////////////////////////////////////

Процедура BeginConnectEquipment(ОповещениеПриПодключении) Экспорт
	   
	ОбъектДрайвера = Неопределено;
	
	Устройство = HardwareServer.GetConnectionSettings(, "BarcodeScanner");
			
	// Проверим, не подключено ли устройство ранее.
	ПодключенноеУстройство = ПолучитьПодключенноеУстройство(globalEquipments.ConnectionSettings, Устройство.Hardware);
	
	Если ПодключенноеУстройство = Неопределено Тогда // Если устройство не было подключено ранее.
		
		ОбработчикДрайвераМодуль = ПолучитьОбработчикДрайвера(Устройство.EquipmentType);
		

		// Синхронные
		ОбъектДрайвера = ПолучитьОбъектДрайвера(Устройство);
		Если ОбъектДрайвера = Неопределено Тогда
			Если ОповещениеПриПодключении <> Неопределено Тогда
				// Сообщить об ошибке, что не удалось загрузить драйвер.
				ОписаниеОшибки = НСтр("ru='%Наименование%: Не удалось загрузить драйвер устройства.
									|Проверьте, что драйвер корректно установлен и зарегистрирован в системе.'");
				ОписаниеОшибки = СтрЗаменить(ОписаниеОшибки, "%Наименование%", Устройство.Hardware);
				РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Ложь, ОписаниеОшибки);
				ВыполнитьОбработкуОповещения(ОповещениеПриПодключении, РезультатВыполнения);
			КонецЕсли;
			Return;
		Иначе
			ВыходныеПараметры = Неопределено;
			Результат = ОбработчикДрайвераМодуль.ПодключитьУстройство(ОбъектДрайвера, Устройство.ConnectParameters, ВыходныеПараметры);
			
			Если Результат Тогда
				
				Если ВыходныеПараметры.Количество() >= 2 Тогда
					Устройство.Вставить("ИсточникСобытия", ВыходныеПараметры[0]);
					Устройство.Вставить("ИменаСобытий",    ВыходныеПараметры[1]);
				Иначе
					Устройство.Вставить("ИсточникСобытия", "");
					Устройство.Вставить("ИменаСобытий",    Неопределено);
				КонецЕсли;

				МассивПараметровПодключения = globalEquipments.ConnectionSettings; //Массив - 
				МассивПараметровПодключения.Добавить(Устройство);
				
				Если ОповещениеПриПодключении <> Неопределено Тогда
					ОписаниеОшибки = НСтр("ru='Ошибок нет.'");
					РезультатВыполнения = Новый Структура("Result, ОписаниеОшибки, ПараметрыПодключения", Истина, ОписаниеОшибки, Устройство.ConnectParameters);
					ВыполнитьОбработкуОповещения(ОповещениеПриПодключении, РезультатВыполнения);
				КонецЕсли;
				
			Иначе
				// Сообщим пользователю о том, что не удалось подключить устройство.
				Если ОповещениеПриПодключении <> Неопределено Тогда
					ОписаниеОшибки = НСтр("ru='Не удалось подключить устройство ""%Наименование%"": %ОписаниеОшибки% (%КодОшибки%)'");
					ОписаниеОшибки = СтрЗаменить(ОписаниеОшибки, "%ОписаниеОшибки%", ВыходныеПараметры[1]);
					ОписаниеОшибки = СтрЗаменить(ОписаниеОшибки, "%КодОшибки%"     , ВыходныеПараметры[0]);
					РезультатВыполнения = ПараметрыВыполненияОперацииНаОборудовании(Ложь, ОписаниеОшибки);
					ВыполнитьОбработкуОповещения(ОповещениеПриПодключении, РезультатВыполнения);
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	

	
	Иначе // Устройство было подключено ранее.
		ПодключенноеУстройство.КоличествоПодключенных = ПодключенноеУстройство.КоличествоПодключенных + 1;
		Если ОповещениеПриПодключении <> Неопределено Тогда
			ОписаниеОшибки = НСтр("ru='Ошибок нет.'");
			РезультатВыполнения = Новый Структура("Результат, ОписаниеОшибки, ПараметрыПодключения", Истина, ОписаниеОшибки, ПодключенноеУстройство.ПараметрыПодключения);
			ВыполнитьОбработкуОповещения(ОповещениеПриПодключении, РезультатВыполнения);
		КонецЕсли;
	КонецЕсли;
			


КонецПроцедуры

Функция ПолучитьОбъектДрайвера(ДанныеДрайвера, ТекстОшибки = Неопределено)
	
	ОбъектДрайвера = Неопределено;
	
	Для Каждого ДрайверПО Из globalEquipments.Drivers Цикл
		Если ДрайверПО.Ключ = ДанныеДрайвера.Driver  Тогда
			ОбъектДрайвера = ДрайверПО.Значение;
			Возврат ОбъектДрайвера;
		КонецЕсли;
	КонецЦикла;
	
	Если ОбъектДрайвера = Неопределено Тогда

			ProgID = ДанныеДрайвера.AddInID;
			Если ПустаяСтрока(ProgID) Тогда
				ОбъектДрайвера = ""; // Драйвер не требуется
			Иначе
				ProgID1 = ?(Найти(ProgID, "|") > 0, Сред(ProgID, 1, Найти(ProgID, "|")-1), ProgID); 
				ProgID2 = ?(Найти(ProgID, "|") > 0, Сред(ProgID, Найти(ProgID, "|")+1), ProgID); 

				ИмяОбъекта = Сред(ProgID1, Найти(ProgID1, ".") + 1); 
				Префикс = Сред(ProgID1, 1, Найти(ProgID1, ".")); 
				ProgID2 = Префикс + СтрЗаменить(ИмяОбъекта, ".", "_") + "." + ИмяОбъекта;

					СсылкаНаДрайвер = ПолучитьНавигационнуюСсылку(ДанныеДрайвера.Driver, "Driver");
					Результат = ПодключитьВнешнююКомпоненту(СсылкаНаДрайвер, СтрЗаменить(ИмяОбъекта, ".", "_"));

				ОбъектДрайвера = Новый (ProgID2);
			КонецЕсли;

		
		Если ОбъектДрайвера <> Неопределено Тогда
			globalEquipments.Drivers.Вставить(ДанныеДрайвера.Driver, ОбъектДрайвера);
			ОбъектДрайвера = globalEquipments.Drivers[ДанныеДрайвера.Driver];
		КонецЕсли;
		
	КонецЕсли;   
		
	Возврат ОбъектДрайвера;
	
КонецФункции

