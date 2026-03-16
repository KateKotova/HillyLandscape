/**
 * Пакет перечислимых типов.
 */
package enumerations
{
	import flash.utils.describeType;
	
	/**
	 * Класс перечисления.
	 */
	public class Enumeration
	{
		/**
		 * Определение, является заданный класс перечислением.
		 * @param parEnumerationClass Класс перечисления.
		 * @return true - класс является перечисление, false - нет.
		 */
		public static function IsEnumeration( parEnumerationClass: Class )
			: Boolean
		{
			// factory - тег объекта XML для описания объекта ActionScript,
			// полученного методом describeType( value: * ): XML,
			// который есть только тогда, когда объект ActionScript -
			// объект класса или функция конструктора.
			// В атрибуте type тега factory можно увидеть полное имя класса.
			// Вложенные теги extendsClass содержат все классы,
			// от которых наследуется данный класс, они выводятся иерархически.
			// В атрибуте type тега extendsClass можно посмотрет полное имя
			// класса предка.
			// Таким образом можно посмотреть, если ли среди имён классов-предков
			// заданного класса имя текущего класса, потому что заданный класс
			// должен быть перечислением, иначе результат не будет иметь смысла.
			
			// Наглядный пример, как устроен тег factory.
			// Функция trace( classDescription.factory.toXMLString( ) )
			// при том, когда parEnumerationClass == UnitType,
			// на экран покажет следующее:
			// <factory type="houseBurster.model::UnitType">
			// 	<extendsClass type="enumerations::UintEnumeration"/>
			// 	<extendsClass type="enumerations::Enumeration"/>
			// 	<extendsClass type="Object"/>
			// 	<constructor>
			// 		<parameter index="1" type="uint" optional="false"/>
			// 	</constructor>
			// 	<variable name="Value" type="uint"/>
			// </factory>
			// Здесь видно, что при вызове classDescription.factory.extendsClass
			// получится такой список:
			// <extendsClass type="enumerations::UintEnumeration"/>
			// <extendsClass type="enumerations::Enumeration"/>
			// <extendsClass type="Object"/>
			// в нём проверяется, есть ли значения аттрибута type,
			// которое равно значению атрибута type в теге factory
			// уже в другом XML-объекте, представляющем данный класс.
			// Если полученный при таких условиях не пуст,
			// то заданный класс - поток данного класса.		
			
			return describeType( parEnumerationClass ).factory.extendsClass
				.( @type	== describeType( Enumeration ).factory.@type
				.length( ) > 0 );
		} // IsEnumeration
		
		/**
		 * Все значения перечисления в виде массива.
		 * @param parEnumerationClass Класс перечисления.
		 * @return null, если заданный класс не является перечислением
		 * (наследником Enumeration), иначе список возможных значений перечисления,
		 * то есть его элементов, которые являются статическими константными полями.
		 */
		public static function GetElements( parEnumerationClass: Class )
			: Vector.< Enumeration >		
		{
			// Заданный класс должен быть перечислением, иначе результат
			// не будет иметь смысла.
			if ( ! Enumeration.IsEnumeration( parEnumerationClass ) )
				return null;			
			
			// Функция describeType( value: * ): XML создает объект XML,
			// описывающий объект ActionScript, который именуется как параметр метода.
			// В этом методе реализована концепция программирования отражение
			// для языка ActionScript.
			// Если параметр value является экземпляром типа, возвращаемый объект XML
			// содержит все свойства экземпляра, имеющие этот тип, но НЕ содержит
			// статических свойств.
			// А значения перечисления - как раз СТАТИЧЕСКИЕ констрантные поля.
			// Чтобы получить статические свойства типа, надо передать для параметра
			// value сам тип. А в этой функции как раз есть нужный параметр -
			// parEnumerationClass.			
			var classDescription: XML = describeType( parEnumerationClass );			
			// Элементы перечисления - статические константные поля.
			var elements: Vector.< Enumeration > = new Vector.< Enumeration >( );
			
			// constant - тег объекта XML для свойств, определённых с помощью
			// инструкции const, содержит следующие атрибуты:
			// name	- имя константы, type	- тип данных константы.
			// Вот так полчается список констант.
			var classConstants: XMLList = classDescription..constant;
			for each ( var classConstant: XML in classConstants )
				elements.push( parEnumerationClass[ classConstant.@name ] );
				
			return elements;
		} // GetElements
		
		/**
		 * Возврат элемента перечисления по его значению.
		 * @param parValue Значение элемента перечисления перечисления.
		 * @param parEnumerationClass Класс перечисления.
		 * @return null, если в перечислении нет элементов с заданным значением,
		 * иначе возвращается ссылка на статический известных элемент перечисления
		 * с заданным значеним.
		 */
		public static function GetElementByValue( parValue: *,
			parEnumerationClass: Class ): Enumeration
		{
			// Заданный класс должен быть перечислением, иначе результат
			// не будет иметь смысла.
			if ( ! Enumeration.IsEnumeration( parEnumerationClass ) )
				return null;

			// Список существующих константных элементов.
			var classConstants: XMLList
				= describeType( parEnumerationClass )..constant;
			for each ( var classConstant: XML in classConstants )
				// Если соответствие найдено, можно не смотреть список до конца.
				if ( parEnumerationClass[ classConstant.@name ].Value == parValue )
					return parEnumerationClass[ classConstant.@name ];
			
			// Здесь выход, если ничего не нашлось.
			return null;
		} // GetElementByValue
		
		/**
		 * Возврат имени элемента перечисления по его значению.
		 * @param parValue Значение элемента перечисления перечисления.
		 * @param parEnumerationClass Класс перечисления.
		 * @return null, если в перечислении нет элементов с заданным значением,
		 * иначе возвращается имя-строка известного элемента перечисления
		 * с заданным значеним.
		 */
		public static function GetElementNameByValue( parValue: *,
			parEnumerationClass: Class ): String
		{
			// Заданный класс должен быть перечислением, иначе результат
			// не будет иметь смысла.
			if ( ! Enumeration.IsEnumeration( parEnumerationClass ) )
				return null;

			// Список существующих константных элементов.
			var classConstants: XMLList
				= describeType( parEnumerationClass )..constant;
			for each ( var classConstant: XML in classConstants )
				// Если соответствие найдено, можно не смотреть список до конца.
				if ( parEnumerationClass[ classConstant.@name ].Value == parValue )
					return classConstant.@name;
			
			// Здесь выход, если ничего не нашлось.
			return null;
		} // GetElementNameByValue		
		
		/**
		 * Возвращает строковое представление перечисления:
		 * имён элементов и из значений.
		 * Только в методе toString я всегда использую строковые значения в лоб
		 * без помещения их в качестве констант класса.
		 * @param parEnumerationClass Класс перечисления.
		 * @return Строковое представление перечисления.
		 */
		public static function toString( parEnumerationClass: Class ): String
		{
			// Заданный класс должен быть перечислением, иначе результат
			// не будет иметь смысла.
			if ( ! Enumeration.IsEnumeration( parEnumerationClass ) )
				return null;
				
			var classDescription: XML = describeType( parEnumerationClass );
			// Записывается сначала название самого класса.
			var stringDescription: String = classDescription.factory.@type
				+ ": ";
			var classConstants: XMLList = classDescription..constant;
			for each ( var classConstant: XML in classConstants )
				stringDescription += classConstant.@name + "="
					+ parEnumerationClass[ classConstant.@name ].Value + " ";	
			
			return stringDescription;
		} // toString		
	} // Enumeration
} // enumerations
