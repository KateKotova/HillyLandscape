/**
 * Пакет логических представлений игровых объектов.
 */
package hillyLandscape.model
{	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	/*import flash.utils.CompressionAlgorithm;*/
	import enumerations.Enumeration;

	/**
	 * Класс размещения тайлов на ландшафте переменной высоты.
	 * Каждый тайл располагается в плоскости параллельно плоскости XOY.
	 * Вначале любой тайл, находится в координатной плоскости XOY,
	 * разделённой сеткой.
	 * Одну ячейку кординатной сети занимает один тайл.
	 * Ячейки сетки пронумерованы целочисленными индексами от нуля.
	 * Два индекса соответствуют положению тайла в строке по оси OY
	 * и в столбце по оси OX.
	 * Самый первый тайл имеет координаты ячейки [0,0].
	 * Информация о тайлах хранится в матрице - двумерном массиве,
	 * инексы строк и столбцов которого соответствуют номерам ячеек
	 * размещения тайлов в плоскостях, разделённых сетками и параллельными
	 * плоскости XOY.
	 * О тайлах хранится следующая информация: тип и высота.
	 * Положение тайла может измениться по высоте - координата по оси OZ.
	 * В изометрической проекции ось OZ направлена вертикально снизу вверх.
	 * Каждому типу тайла соответствует изображение, которое будет проецироваться
	 * на сцену в месте, соответствующем положению тайла.
	 * Информация о тайлах может храниться в xml-документах.
	 */ 
	public final class TilesLocations extends EventDispatcher
	{
		/**
		 * Имя XML-файла по умолчанию.
		 */
		private static const DEFAULT_XML_FILE_NAME: String
			= "TilesLocations.xml";
		/**
		 * Фильтр загрузки xml-документа.
		 */ 
		private static const XML_FILE_FILTER: FileFilter =
			new FileFilter( "XML-документы (*.xml)", "*.xml" );
		/**
		 * Название набора символов, используемого для интерпретации байтов
		 * в xml-файлах.
		 */
		private static const XML_FILE_CHAR_SET_NAME: String = "windows-1251";			
		
		/**
		 * Сообщение об ошибке загрузки XML-файла.
		 */
		private static const XML_FILE_LOADING_ERROR_MESSAGE: String
			= "Ошибка загрузки XML-файла: ";
		/**
		 * Сообщение об ошибке сохранения XML-файла.
		 */
		private static const XML_FILE_SAVING_ERROR_MESSAGE: String
			= "Ошибка сохранения XML-файла: ";			
		/**
		 * Сообщение о об ошибке о том, что загруженный файл не является XML.
		 */
		private static const LOADED_FILE_IS_NOT_XML_ERROR_MESSAGE: String
			= "Файл не является XML.";
		/**
		 *  Сообщение об попытке загрузки XML-файла.
		 */
		private static const XML_FILE_LOADING_ATTEMPT_MESSAGE: String
			= "Попытка загрузки матрицы размещений тайлов из XML-файла "
			+ "по заданному пути:";
		/**
		 *  Сообщение об успешной загрузке XML-файла.
		 */
		private static const XML_FILE_LOADING_COMPLETE_MESSAGE: String
			= "Успешная загрузка матрицы размещений тайлов из XML-файла.";
		/**
		 *  Сообщение об успешном сохранении XML-файла.
		 */
		private static const XML_FILE_SAVING_COMPLETE_MESSAGE: String
			= "Успешное сохранение матрицы размещений тайлов в файл.";			
			
		/**
		 * Название типа события успешной загрузки XML-файла.
		 */
		public static const XML_FILE_LOADING_COMPLETE: String
			= "XMLFileLoadingComplete";
		/**
		 * Название типа события возникновения ошибки при загрузке XML-файла.
		 */
		public static const XML_FILE_LOADING_ERROR: String
			= "XMLFileLoadingError";			
		/**
		 * Название типа события успешного сохранения XML-файла.
		 */
		public static const XML_FILE_SAVING_COMPLETE: String
			= "XMLFileSavingComplete";
		/**
		 * Название типа события возникновения ошибки при сохранении XML-файла.
		 */
		public static const XML_FILE_SAVING_ERROR: String
			= "XMLFileSavingError";				
		
		/**
		 * Имя тега корня документа XML-документа с информацией о тайлах.
		 */
		public static const ROOT_TAG_NAME: String = "tilesHeight";
		/**
		 * Имя атрибута корневого тега XML-документа с информацией о тайлах,
		 * содержащего количетсов строк матрицы - количество ячеек размещения
		 * по оси OY.
		 */
		public static const Y_ROWS_COUNT_ATTRIBUTE_NAME: String = "YRowsCount";
		/**
		 * Имя атрибута корневого тега XML-документа с информацией о тайлах,
		 * содержащего количетсов столбцов матрицы - количество ячеек размещения
		 * по оси OX.
		 */		
		public static const X_COLUMNS_COUNT_ATTRIBUTE_NAME: String
			= "XColumnsCount";
		/**
		 * Имя тега строки матрицы.
		 */
		public static const Y_ROW_TAG_NAME: String = "yRow";
		/**
		 * Имя тега столбца матрицы.
		 */		
		public static const X_COLUMN_TAG_NAME: String = "xColumn";
		/**
		 * Имя тега типа тайла, в котором хранится значение, соответствующее
		 * одному из значений статических полей перечисления TileType.
		 */			
		public static const TYPE_TAG_NAME: String = "type";
		/**
		 * Имя тега высоты расположения тайла по оси OZ в пикселях.
		 */			
		public static const Z_HEIGHT_TAG_NAME: String = "height";
		
		/**
		 * Минимальное количество ячеек в ряду, строке или столбце.
		 */	
		public static const MINIMUM_LINES_NUMBER: uint = 1;
		/**
		 * Максимальное количество ячеек в ряду, строке или столбце.
		 */
		public static const MAXIMUM_LINES_NUMBER: uint = 15;
		/**
		 * Количество ячеек в ряду, строке или столбце, по умолчанию.
		 */		
		public static const DEFAULT_LINES_NUMBER: uint = 10;	
			
		/**
		 * Минимальное значение высоты расположения тайла по оси OZ.
		 */				
		public static const MINIMUM_Z_HEIGHT: Number = -150;
		/**
		 * Максимальное значение высоты расположения тайла по оси OZ.
		 */					
		public static const MAXIMUM_Z_HEIGHT: Number = 150;
		/**
		 * Высота расположения тайла по оси OZ по умолчанию.
		 */		
		public static const DEFAULT_Z_HEIGHT: Number = 0;			
		
		/**
		 * Количество строк в матрице тайлов - количество ячеек размещения
		 * тайлов по оси OY.
		 */
		private var _YRowsCount: uint = TilesLocations.DEFAULT_LINES_NUMBER;
		/**
		 * Количество столбцов в матрице тайлов - количество ячеек размещения
		 * тайлов по оси OX.
		 */		
		private var _XColumnsCount: uint = TilesLocations.DEFAULT_LINES_NUMBER;
		
		/**
		 * Матрица, инексы строк и столбцов которой соответствуют номерам ячеек
		 * размещения тайлов в плоскостях, разделённых сетками и параллельными
		 * плоскости XOY. О тайлах хранится следующая информация: тип и высота -
		 * координата в пикселях по оси OZ.
		 */
		private var _Locations: Vector.< Vector.< TileZLocation > > =
			new Vector.< Vector.< TileZLocation > >( );
			
		/**
		 * Загрузчик данных с URL-адреса для XML-файла.
		 */
		private var _XMLFileURLLoader: URLLoader = new URLLoader( );
		/**
		 * Ссылка на файловую переменную открытия XML-файла:
		 * одновременно для всех операций (открытия, сохранения)
		 * почему-то нельзя использовать один и от же объект класса FileReference.
		 */
		private var _OpenXMLFileReference: FileReference = new FileReference( ); 		
			
		/**
		 * Конструктор размещения тайлов на ландшафте переменной высоты.
		 */		
		public function TilesLocations( ): void
		{
			// Матрица размещения тайлов - по умолчанию.
			this.SetDefaultLocations( );
			
			// Регистрирация объекта-прослушивателя события
			// выбора файла в диалоговом окне открытия файла.
			this._OpenXMLFileReference.addEventListener( Event.SELECT,
				this.FileSelectedListener );
			// Регистрирация объекта-прослушивателя события
			// возникновения ошибки при загрузке данных из файла.
			this._OpenXMLFileReference.addEventListener( IOErrorEvent.IO_ERROR,
				this.XMLFileLoadingIOErrorListener );
			// Регистрирация объекта-прослушивателя события
			// загрузки файла в диалоговом окне открытия файла.
			this._OpenXMLFileReference.addEventListener( Event.COMPLETE,
				this.XMLFileLoadingCompleteListener );
				
			// Формат загружаемых данных с URL-адреса XML-файла.
			this._XMLFileURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			// Регистрирация объекта-прослушивателя события
			// возникновения ошибки при загрузке данных с URL-адреса XML-файла.
			this._XMLFileURLLoader.addEventListener
				( IOErrorEvent.IO_ERROR, this.XMLFileLoadingIOErrorListener );
			// Регистрирация объекта-прослушивателя события
			// успешной загрузки данных с URL-адреса XML-файла.
			this._XMLFileURLLoader.addEventListener( Event.COMPLETE,
				this.XMLFileLoadingCompleteListener );					
		} // TilesLocations
		
		/**
		 * Перемещение тайла с заданными индексами матрицы по оси аппликат.
		 * @param parYRow Индекс строки размещения ячейки тайла по оси OY.
		 * @param parXColumn Индекс столбца размещения ячейки тайла по оси OX.
		 * @param parZOffset Смещение по оси OZ.
		 * @return Реальное смещение, которое произошло для данного тайла по оси OZ:
		 * заданы предельные границы значения высоты расположения тайла по оси OZ,
		 * нарушать которые нельзя.
		 */
		public function MoveZ( parYRow: uint, parXColumn: uint, parZOffset: Number )
			: Number
		{
			// Если не существует тайла по заданным индексам ячейки,
			// то перемещения нет.
			if ( ( parYRow > this._YRowsCount )
					|| ( parXColumn > this._XColumnsCount ) )
				return 0;
				
			// Текущее значение аппликаты для заданной ячейки.
			var zHeight: Number = this._Locations[ parYRow ][ parXColumn ].Z;
			// Предварительное новое значение аппликаты для заданной ячейки
			// при смещении на заданную величину.
			var preliminaryNewZHeight: Number = zHeight + parZOffset;
			// Реальное новое значение аппликаты для заданной ячейки при смещении
			// на величину, близкую к заданной в пределах установленных границ.
			var realNewZHeight: Number =
				( preliminaryNewZHeight < TilesLocations.MINIMUM_Z_HEIGHT )
				? TilesLocations.MINIMUM_Z_HEIGHT
				:
				(
					( preliminaryNewZHeight > TilesLocations.MAXIMUM_Z_HEIGHT )
					? TilesLocations.MAXIMUM_Z_HEIGHT
					: preliminaryNewZHeight
				); // realNewZHeight
			
			// Изменение аппликаты тайла.
			this._Locations[ parYRow ][ parXColumn ].Z = realNewZHeight;
			
			// Реальное смещение по оси OZ, которое произведено данной ячейкой.
			return realNewZHeight - zHeight;
		} // MoveZ		
		
		/**
		 * Загрузка матрицы размещения тайлов из фала, выбранного пользователем.
		 */
		public function LoadFromUserSelectedFile( ): void
		{
			// Вызов этого метода может повлечь за собой событие Event.SELECT
			// и вызов метода this.FileSelectedListener.
			this._OpenXMLFileReference.browse( [ TilesLocations.XML_FILE_FILTER ] );
		} // LoadFromUserSelectedFile
		
		/**
		 * Метод-прослушиватель события выбора файла в диалоговом окне.
		 * @param parEvent Событие возникновения ошибки при выполнении
		 * операция отправки или загрузки.
		 */		
		private function FileSelectedListener( parEvent: Event ): void
		{			
			try
			{
				// Загрузка данных из файла. 
				// Вызов этого метода может повлечь за собой событие Event.COMPLETE,
				// и вызов метода this.XMLFileLoadingCompleteListener.
				// Вызов этого метода может повлечь за собой событие
				// IOErrorEvent.IO_ERROR,
				// и вызов метода this.XMLFileLoadingIOErrorListener.
				this._OpenXMLFileReference.load( );			
			} // try
			catch ( error: Error )
			{
				// Сообщение об ошибке загрузки XML-файла.
				var errorMessage: String = TilesLocations
					.XML_FILE_LOADING_ERROR_MESSAGE + error.message;
				trace( errorMessage );
				// Передача события возникновения ошибки при загрузке XML-файла
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища размещений тайлов.
				// Для пользовательского объекта ErrorEvent число errorID
				// является значением параметра id, представленного в конструкторе.
				this.dispatchEvent( new ErrorEvent( TilesLocations
					.XML_FILE_LOADING_ERROR, false, false, errorMessage, error.errorID ) );
			} // catch
		} // FileSelectedListener
		
		/**
		 * Загрузка матрицы размещения тайлов из XML-фала.
		 * @param parXMLFilePath Путь к XML-фалу.
		 */
		public function LoadFromXMLFile( parXMLFilePath: String ): void
		{
			try
			{
				trace( TilesLocations.XML_FILE_LOADING_ATTEMPT_MESSAGE + parXMLFilePath );
				// Загрузка данных с URL-адреса XML-файла. 
				// Вызов этого метода может повлечь за собой событие Event.COMPLETE,
				// и вызов метода this.XMLFileLoadingCompleteListener.
				// Вызов этого метода может повлечь за собой событие
				// IOErrorEvent.IO_ERROR,
				// и вызов метода this.XMLFileLoadingIOErrorListener.
				this._XMLFileURLLoader.load( new URLRequest( parXMLFilePath ) );				
			} // try
			// В частности, возникает ошибка, когда не получается загрузить
			// файл из Интернета или с сервера, потому что у swf-файла не установлены
			// права доступа.
			catch ( error: Error )
			{
				// Сообщение об ошибке загрузки XML-файла.
				var errorMessage: String = TilesLocations
					.XML_FILE_LOADING_ERROR_MESSAGE + error.message;
				trace( errorMessage );
				// Передача события возникновения ошибки при загрузке XML-файла
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища размещений тайлов.
				// Для пользовательского объекта ErrorEvent число errorID
				// является значением параметра id, представленного в конструкторе.
				this.dispatchEvent( new ErrorEvent( TilesLocations
					.XML_FILE_LOADING_ERROR, false, false, errorMessage, error.errorID ) );
			} // catch		
		} // LoadFromXMLFile		
		
		/**
		 * Метод-прослушиватель события возникновения ошибки при загрузке данных
		 * с URL-адреса XML-файла.
		 * @param parIOErrorEvent Событие возникновения ошибки при выполнении
		 * операция отправки или загрузки.
		 */
		private function XMLFileLoadingIOErrorListener
			( parIOErrorEvent: IOErrorEvent ): void
		{
			// Сообщение об ошибке загрузки XML-фала.
			var errorMessage: String = TilesLocations
				.XML_FILE_LOADING_ERROR_MESSAGE + parIOErrorEvent.text;
			trace( errorMessage );
			// Передача события возникновения ошибки при загрузке XML-фала
			// в поток событий, целью - объбектом-получателем - которого
			// является данный экземпляр хранилища размещений тайлов.
			// Для пользовательского объекта ErrorEvent число errorID
			// является значением параметра id, представленного в конструкторе.
			this.dispatchEvent( new ErrorEvent( TilesLocations
				.XML_FILE_LOADING_ERROR, parIOErrorEvent.bubbles,
				parIOErrorEvent.cancelable, errorMessage, parIOErrorEvent.errorID ) );				
		} // XMLFileLoadingIOErrorListener
		
		/**
		 * Метод-прослушиватель события успешной загрузки файла,
		 * в котором предполагается, что находтся XML-данные.
		 * @param parEvent Событие.
		 */
		private function XMLFileLoadingCompleteListener( parEvent: Event ): void
		{
			// Результат - в виде необработанных двоичных данных, получаемый
			// из данных загрузчика - объбекта-получателя события.			
			/*var byteArray: ByteArray = this._OpenXMLFileReference.data as ByteArray;*/
			/*var byteArray: ByteArray = this._XMLFileURLLoader.data as ByteArray;*/
			var byteArray: ByteArray = parEvent.target.data as ByteArray;
			// XML-результат выполненного запроса к базе данных MySQL, полученный
			// при считывании из потока байт двоичного массива многобайтовой строки
			// с использованием набора символов, используемого в базе данных.
			var xmlData: XML = new XML( byteArray.readMultiByte
				( byteArray.length, TilesLocations.XML_FILE_CHAR_SET_NAME ) );	

			// Надо проверять, были ли загружены именно XML-данные.
			if ( xmlData == null )
			{			
				// Должен был загрузиться XML-файл, а не что-то ещё.
				
				// Сообщение об ошибке загрузки файла, не являющегося .xml.
				var errorMessage: String = TilesLocations
					.LOADED_FILE_IS_NOT_XML_ERROR_MESSAGE;
				trace( errorMessage );
				// Передача события возникновения ошибки при загрузке XML-файла
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища размещений тайлов.
				this.dispatchEvent( new ErrorEvent( TilesLocations
					.XML_FILE_LOADING_ERROR, false, false, errorMessage ) );
				return;			
			} // if ( xmlData == null )
			
			// Преобразование XML-документа в матрицу размещений тайлов.
			this.SetXML( xmlData );
		
			trace( TilesLocations.XML_FILE_LOADING_COMPLETE_MESSAGE );
			// Передача события успешной загрузки XML-файла в поток событий, целью -
			// объбектом-получателем - которого является данное
			// хранилище размещений тайлов.
			this.dispatchEvent( new Event( TilesLocations
				.XML_FILE_LOADING_COMPLETE ) );			
		} // XMLFileLoadingCompleteListener
		
		/**
		 * Сохранение матрицы размещения тайлов в XML-фал.
		 */
		public function SaveToXMLFile( ): void
		{
			try
			{
				// Обеспечение работы средств загрузки файлов
				// между компьютером пользователя и сервером. 
				( new FileReference( ) ).save( this.GetXML( ).toXMLString( ),
					TilesLocations.DEFAULT_XML_FILE_NAME );
				trace( TilesLocations.XML_FILE_SAVING_COMPLETE_MESSAGE );
				// Передача события успешного сохранения XML-файла в поток событий,
				// целью - объбектом-получателем - которого является данное
				// хранилище размещений тайлов.
				this.dispatchEvent( new Event( TilesLocations
					.XML_FILE_SAVING_COMPLETE ) );					
			} // try
			catch ( error: Error )
			{
				// Сообщение об ошибке сохранения XML-файла.
				var errorMessage: String = TilesLocations
					.XML_FILE_SAVING_ERROR_MESSAGE + error.message;
				trace( errorMessage );
				// Передача события возникновения ошибки при сохранении XML-файла
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища размещений тайлов.
				// Для пользовательского объекта ErrorEvent число errorID
				// является значением параметра id, представленного в конструкторе.
				this.dispatchEvent( new ErrorEvent( TilesLocations
					.XML_FILE_SAVING_ERROR, false, false, errorMessage, error.errorID ) );				
			} // catch		
		} // SaveToXMLFile
		
		/**
		 * Установака матрицы размещений в первоначальное состояние.
		 * В матрице инексы строк и столбцов соответствуют номерам ячеек
		 * размещения тайлов в плоскостях, разделённых сетками и параллельными
		 * плоскости XOY. О тайлах хранится следующая информация: тип и высота -
		 * координата в пикселях по оси OZ.
		 */
		public function SetDefaultLocations( ): void
		{
			// Обнуление матрицы: сейчас она будет переписываться заново.
			this._Locations.length = 0;
			
			// Количество строк и столбцов - по умолчанию.
			this._YRowsCount = TilesLocations.DEFAULT_LINES_NUMBER;
			this._XColumnsCount = TilesLocations.DEFAULT_LINES_NUMBER;
			
			for ( var yRow: uint = 0; yRow < this._YRowsCount; yRow++ )
			{		
				this._Locations[ yRow ] = new Vector.< TileZLocation >( );
				
				for ( var xColumn: uint = 0; xColumn < this._XColumnsCount; xColumn++ )
					this._Locations[ yRow ][ xColumn ] = new TileZLocation
						( TileType.UNDEFINED, TilesLocations.DEFAULT_Z_HEIGHT );				
			} // for ( var yRow: uint = 0...
		} // SetDefaultLocations
			
		/**
		 * Метод получения XML-документа из матрицы размещений тайлов.
		 * @return XML-документ с информацией о размещении тайлов.
		 */			
		public function GetXML( ): XML
		{
			// XML-документ, содержащий информацию о типах и высотах тайлов,
			// распопложенных в строках и столбцах.
			// Инициализация корня документа, запись количества строк и столбцов.
			var zHeightXML: XML = <{ TilesLocations.ROOT_TAG_NAME }
				{ TilesLocations.Y_ROWS_COUNT_ATTRIBUTE_NAME }={ this._YRowsCount }
				{ TilesLocations.X_COLUMNS_COUNT_ATTRIBUTE_NAME }
				={ this._XColumnsCount } />;
			
			// Дочерний XML-элемент - строка.
			var yRowXML: XML;
			// Дочерний XML-элемент - столбец.
			var xColumnXML: XML;
			
			for ( var yRow: uint = 0; yRow < this._YRowsCount; yRow++ )
			{
				yRowXML = <{ TilesLocations.Y_ROW_TAG_NAME }/>;
				for ( var xColumn: uint = 0; xColumn < this._XColumnsCount; xColumn++ )
				{
					xColumnXML =
						<{ TilesLocations.X_COLUMN_TAG_NAME }> 
							<{ TilesLocations.TYPE_TAG_NAME }>
								{ this._Locations[ yRow ][ xColumn ].Type.Value }
							</{ TilesLocations.TYPE_TAG_NAME }> 
							<{ TilesLocations.Z_HEIGHT_TAG_NAME }>
								{ this._Locations[ yRow ][ xColumn ].Z }
							</{ TilesLocations.Z_HEIGHT_TAG_NAME }> 
						</{ TilesLocations.X_COLUMN_TAG_NAME }>;
					
					yRowXML.appendChild( xColumnXML );
				} // for ( var xColumn...
				zHeightXML.appendChild( yRowXML );
			} // for ( var yRow...
			
			/*trace( zHeightXML.toXMLString( ) );*/
			return zHeightXML;
		} // GetXML
	
		/**
		 * Получение корректного значения количества рядов, строк или столбцов
		 * на основе заданной величины.
		 * @param parZHeightXML XML-документ, содержащий информацию о типах
		 * и высотах тайлов, распопложенных в строках и столбцах.
		 * @param parLinesCountAttributeName Имя атрибута корневого тега
		 * XML-документа с информацией о тайлах, содержащего количетсов
		 * рядов, строк или столбцов матрицы.
		 * @return Корректное значение количества рядов матрицы, ограниченное
		 * в пределах диапазона от минимального до максимального значения.
		 */
		private static function GetCorrectLinesCountFromTilesHeightXML
			( parZHeightXML: XML, parLinesCountAttributeName: String ): uint
		{
			// Корректное количество рядов матрицы.
			var linesCount: int;
			// Если атрибут не существует.
			if ( parZHeightXML.@[ parLinesCountAttributeName ] == undefined )
				linesCount = TilesLocations.DEFAULT_LINES_NUMBER;
			else
				// Преобразование отрицательного числа в положительное
				// имеет непредсказуемо большой положительный резултат.
				// Поэтому здесь рассматривается int, а не uint.
				linesCount = int( parZHeightXML.@[ parLinesCountAttributeName ] );
			// Количество рядов в пределах заданных границ.			
			linesCount = ( linesCount < TilesLocations.MINIMUM_LINES_NUMBER )
				? TilesLocations.MINIMUM_LINES_NUMBER
				:
				(
					( linesCount > TilesLocations.MAXIMUM_LINES_NUMBER )
					? TilesLocations.MAXIMUM_LINES_NUMBER
					: linesCount
				);
			return uint( linesCount );
		} // GetCorrectLinesCountFromTilesHeightXML		
		
		/**
		 * Метод преобразования XML-документа в матрицу размещений тайлов.
		 * @param parZHeightXML XML-документ, содержащий информацию о типах
		 * и высотах тайлов, распопложенных в строках и столбцах.
		 */			
		public function SetXML( parZHeightXML: XML ): void
		{
			// Обнуление матрицы: сейчас она будет переписываться заново.
			this._Locations.length = 0;
			
			// Получение коректных значений строк и столбцов матрицы.
			this._YRowsCount = TilesLocations
				.GetCorrectLinesCountFromTilesHeightXML
				( parZHeightXML, TilesLocations.Y_ROWS_COUNT_ATTRIBUTE_NAME );
			this._XColumnsCount = TilesLocations
				.GetCorrectLinesCountFromTilesHeightXML
				( parZHeightXML, TilesLocations.X_COLUMNS_COUNT_ATTRIBUTE_NAME );
				
			// Число строк, которые фактически хранятся в файле.	
			var givenYRowsCount: uint = parZHeightXML
				.child( TilesLocations.Y_ROW_TAG_NAME ).length( );
			// Количество строк из файла, котрое будет просмотриваться.
			var viewedYRowsCount: uint = Math.min( this._YRowsCount, givenYRowsCount );
			
			// Индекс строки.
			var yRow: uint;
			// Индекс столбца.
			var xColumn: uint;
			
			for ( yRow = 0; yRow < viewedYRowsCount; yRow++ )
			{		
				this._Locations[ yRow ] = new Vector.< TileZLocation >( );
				
				// Число столбцов, которые фактически хранятся в файле
				// в данной строке.
				var givenXColumnsCount: uint = parZHeightXML
					.child( TilesLocations.Y_ROW_TAG_NAME )[ yRow ]
					.child( TilesLocations.X_COLUMN_TAG_NAME ).length( );				
				// Количество столбцов из файла в данной строке,
				// котрое будет просмотриваться.
				var viewedXColumnsCount: uint = Math.min( this._XColumnsCount,
					givenXColumnsCount );				
				
				for ( xColumn = 0; xColumn < viewedXColumnsCount; xColumn++ )
				{
					// Информации о размещении плитки по оси OZ,
					// которая располагается в текущей строке и текущем столбце.
					var zLocation: XML = parZHeightXML
						.child( TilesLocations.Y_ROW_TAG_NAME )[ yRow ]
						.child( TilesLocations.X_COLUMN_TAG_NAME )[ xColumn ];
					// Тип плитки.
					var type: TileType;
					// Высота в пикселях размещения плитки по оси OZ.
					var zHeight: Number;
					
					// Проверятся, существуют ли теги типа и высоты,
					// они должны быть простыми, то есть не содержать дочерних узлов,
					// а просто значения. Если эти условия не выполняются,
					// то запоминаются занчения по умолчанию.
					
					if ( ( zLocation.child( TilesLocations.TYPE_TAG_NAME ).length( ) < 1 )
							|| ( zLocation.child( TilesLocations.TYPE_TAG_NAME )[ 0 ]
							.hasComplexContent( ) ) )
						type = TileType.UNDEFINED;
					else
					{
						// Если извлечённое значение не соответствует существующему
						// типу, то тип - неопределённый.
						type = TileType( Enumeration.GetElementByValue
							( zLocation.child( TilesLocations.TYPE_TAG_NAME )[ 0 ], TileType ) );
						type = ( type == null ) ? TileType.UNDEFINED : type;
					} // else: if ( ( zLocation.child( TilesLocations.TYPE_TAG_NAME )...
					
					if ( ( zLocation.child( TilesLocations.Z_HEIGHT_TAG_NAME )
							.length( ) < 1 )
							|| ( zLocation.child( TilesLocations.Z_HEIGHT_TAG_NAME )[ 0 ]
							.hasComplexContent( ) ) )
						zHeight = TilesLocations.DEFAULT_Z_HEIGHT;
					else
					{
						// Если извлечённое значение не соответствует дробному числу,
						// то оно становится значением по умолчанию.
						zHeight = Number( zLocation
							.child( TilesLocations.Z_HEIGHT_TAG_NAME )[ 0 ] );
						if ( isNaN( zHeight ) || ( zHeight == Infinity )
								|| ( zHeight == -Infinity ) )
							zHeight = TilesLocations.DEFAULT_Z_HEIGHT;
						else							
							// Высота в пределах заданных границ.			
							zHeight = ( zHeight < TilesLocations.MINIMUM_Z_HEIGHT )
								? TilesLocations.MINIMUM_Z_HEIGHT
								:
								(
									( zHeight > TilesLocations.MAXIMUM_Z_HEIGHT )
									? TilesLocations.MAXIMUM_Z_HEIGHT
									: zHeight
								); // zHeight
					} // if ( ( zLocation.child( TilesLocations.Z_HEIGHT_TAG_NAME )...
					this._Locations[ yRow ][ xColumn ] = new TileZLocation( type, zHeight );
				}	// for ( var xColumn: uint = 0...
				
				// Если в файле фактически записано меньше столбцоы в данной строке,
				// чем нужно, оставшиеся столбцы заполняются значениями по умолчанию.
				for ( xColumn = viewedXColumnsCount; xColumn < this._XColumnsCount;
						xColumn++ )
					this._Locations[ yRow ][ xColumn ] = new TileZLocation
						( TileType.UNDEFINED, TilesLocations.DEFAULT_Z_HEIGHT );				
			} // for ( var yRow: uint = 0...
			
			// Если в файле фактически записано меньше строк, чем нужно,
			// оставшиеся строки заполняются значениями по умолчанию.
			for ( yRow = viewedYRowsCount; yRow < this._YRowsCount; yRow++ )
			{		
				this._Locations[ yRow ] = new Vector.< TileZLocation >( );
				for ( xColumn = 0; xColumn < this._XColumnsCount; xColumn++ )
					this._Locations[ yRow ][ xColumn ] = new TileZLocation
						( TileType.UNDEFINED, TilesLocations.DEFAULT_Z_HEIGHT );
			} // for ( var yRow = viewedYRowsCount...
			
			trace( this.toString( ) );
		} // SetXML
			
		/**
		 * Возвращает строковое представление заданного объекта.
		 * Только в методе toString я всегда использую строковые значения в лоб
		 * без помещения их в качестве констант класса.
		 * @return Строковое представление объекта.
		 */
		public override function toString( ): String
		{
			var result: String = "this._Locations:";
			for ( var yRow: uint = 0; yRow < this._YRowsCount; yRow++ )
			{
				result += "\n\tRow #" + yRow + ":";
				for ( var xColumn: uint = 0; xColumn < this._XColumnsCount; xColumn++ )
					result += "\n\t\tColumn #" + xColumn
						+ ": type=" + this._Locations[ yRow ][ xColumn ].Type.Value
						+ ", height=" + this._Locations[ yRow ][ xColumn ].Z;
			} // for
			
			return result;
		} // toString
		
		/**
		 * Количество строк в матрице тайлов - количество ячеек размещения
		 * тайлов по оси OY.
		 * @return Количество строк в матрице тайлов - количество ячеек размещения
		 * тайлов по оси OY.
		 */		
		public function get YRowsCount( ): uint
    { 
        return this._YRowsCount; 
    }	// get YRowsCount		
		
		/**
		 * Количество столбцов в матрице тайлов - количество ячеек размещения
		 * тайлов по оси OX.
		 * @return Количество столбцов в матрице тайлов - количество
		 * ячеек размещения тайлов по оси OX.
		 */		
		public function get XColumnsCount( ): uint
    { 
        return this._XColumnsCount; 
    }	// get XColumnsCount	
		
		/**
		 * Матрица, инексы строк и столбцов которой соответствуют номерам ячеек
		 * размещения тайлов в плоскостях, разделённых сетками и параллельными
		 * плоскости XOY. О тайлах хранится следующая информация: тип и высота -
		 * координата в пикселях по оси OZ.
		 * @return Матрица информации о размещении тайлов на ландшафте.
		 */		
		public function get Locations( ): Vector.< Vector.< TileZLocation > >
    { 
        return this._Locations; 
    }	// get Locations		
	} // TilesLocations	
} // hillyLandscape.model
