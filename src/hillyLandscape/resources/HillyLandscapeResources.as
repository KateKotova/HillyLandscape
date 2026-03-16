/**
 * Пакет ресурсов игровых объектов.
 */
package hillyLandscape.resources
{	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import enumerations.Enumeration;
	import hillyLandscape.model.TileType;	
	import hillyLandscape.view.TileImage;
	
	/**
	 * Игровые ресурвы, подгружаемые из swf-файла.
	 */
	public final class HillyLandscapeResources extends EventDispatcher
	{
		/**
		 * Имя файла ресурсов из той же папки.
		 */
		private static const RESOURCES_FILE_NAME: String
			= "HillyLandscapeResources.swf";
			
		/**
		 * Сообщение об ошибке загрузки ресурсов.
		 */
		private static const RESOURCES_LOADING_ERROR_MESSAGE: String
			= "Ошибка загрузки ресурсов: ";
		/**
		 * Сообщение о об ошибке о том, что загруженный файл
		 * не является файлом ресурсов .swf.
		 */
		private static const LOADED_FILE_IS_NOT_SWF_ERROR_MESSAGE: String
			= "Файл не является swf-ресурсом: ";
		/**
		 *  Сообщение об успешной загрузке swf-файла ресурсов.
		 */
		private static const RESOURCES_LOADING_COMPLETE_MESSAGE: String
			= "Загрузка ресурсов из swf-файла по заданному пути: ";		
			
		/**
		 * Название типа события успешной загрузки ресурсов.
		 */
		public static const RESOURCES_LOADING_COMPLETE: String
			= "ResourcesLoadingComplete";
		/**
		 * Название типа события возникновения ошибки при загрузке ресурсов.
		 */
		public static const RESOURCES_LOADING_ERROR: String
			= "ResourcesLoadingError";
			
		/**
		 * Ассоциативный массив, ключи воторого - типы тайлов,
		 * значения - объекты, храняющие информацию об именах BitmapData-классов,
		 * соответствующих типам, и величинах смещения картинок тайлов
		 * относительно центров ячеек изометрической сетки.
		 */
		public static const TILES_INFORMATION: Object =
		{
			// Тип тайла не задан - имя класса не определено.
			UNDEFINED:
			{
				ClassName: null,
				Offset: null
			}, // UNDEFINED
			// Имя BitmapData-класса кусочка земли.
			GROUND:
			{
				ClassName: "Ground",
				Offset: new Point( )
			}, // GROUND
			// Имя BitmapData-класса обугленной воронки.
			CRATER:
			{
				ClassName: "Crater",
				Offset: new Point( )
			}, // CRATER
			// Имя BitmapData-класса взрыва.
			EXPLOSION:
			{
				ClassName: "Explosion",
				Offset: new Point( )
			} // EXPLOSION
		}; // TILES_INFORMATION		 
		 
		/**
		 * Словарь, для каждого элемента которого ключом является
		 * тип тайла, а значением - информации об изображении:
		 * сам объект BitmapData - графические денные и смещение,
		 * на которое должен смещаться центр изображения
		 * относительно центра его ячейки изометрической сетки.
		 */
		private var _TilesImages: Dictionary = new Dictionary( ); 
		
		/**
		 * Файловый загрузчик.
		 */
		private var _Loader: Loader = new Loader( );
		
		/**
		 * Создания хранилища игровых ресурсов.
		 */		
		public function HillyLandscapeResources( )
		{
			// Регистрирация объекта-прослушивателя события
			// возникновения ошибки при загрузке ресурсов.
			this._Loader.contentLoaderInfo.addEventListener
				( IOErrorEvent.IO_ERROR, this.ResourcesLoadingIOErrorListener );			
			// Регистрирация объекта-прослушивателя события
			// успешной загрузки ресурсов.
			this._Loader.contentLoaderInfo.addEventListener( Event.COMPLETE,
				this.ResourcesLoadingCompleteListener );			
		} // HillyLandscapeResources
		
		/**
		 * Метод загрузки ресурсов из файла по заданному пути.
		 */
		public function Load( ): void
		{
			try
			{
				this._Loader.load( new URLRequest
					( HillyLandscapeResources.RESOURCES_FILE_NAME ) );
			} // try
			// В частности, возникает ошибка, когда не получается загрузить
			// файл из Интернета или с ервера, потому что у swf-файла не установлены
			// права доступа.
			catch ( error: Error )
			{
				// Сообщение об ошибке загрузки ресурсов.
				var errorMessage: String = HillyLandscapeResources
					.RESOURCES_LOADING_ERROR_MESSAGE + error.message;
				trace( errorMessage );
				// Передача события возникновения ошибки при загрузке ресурсов
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища ресурсов.
				// Для пользовательского объекта ErrorEvent число errorID
				// является значением параметра id, представленного в конструкторе.
				this.dispatchEvent( new ErrorEvent( HillyLandscapeResources
					.RESOURCES_LOADING_ERROR, false, false, errorMessage, error.errorID ) );
			} // catch			
		} // Load
		
		/** 
		 * Метод-прослушиватель события
		 * возникновения ошибки при загрузке ресурсов.
		 * @param parIOErrorEvent Событие возникновения ошибки при выполнении
		 * операции отправки или загрузки.
		 */
		private function ResourcesLoadingIOErrorListener
			( parIOErrorEvent: IOErrorEvent ): void
		{	
			// Сообщение об ошибке загрузки ресурсов.
			var errorMessage: String = HillyLandscapeResources
				.RESOURCES_LOADING_ERROR_MESSAGE + parIOErrorEvent.text;
			trace( errorMessage );
			// Передача события возникновения ошибки при загрузке ресурсов
			// в поток событий, целью - объбектом-получателем - которого
			// является данный экземпляр хранилища ресурсов.
			// Для пользовательского объекта ErrorEvent число errorID
			// является значением параметра id, представленного в конструкторе.
			this.dispatchEvent( new ErrorEvent( HillyLandscapeResources
				.RESOURCES_LOADING_ERROR, parIOErrorEvent.bubbles,
				parIOErrorEvent.cancelable, errorMessage, parIOErrorEvent.errorID ) );
		} // ResourcesLoadingIOErrorListener
		
		/**
		 * Метод-прослушиватель события успешной загрузки ресурсов.
		 * @param parEvent Событие.
		 */
		private function ResourcesLoadingCompleteListener( parEvent: Event ): void
		{
			// this._Loader == LoaderInfo( parEvent.target ).loader
			// == LoaderInfo.loader.
			
			// Загрузиться успешно с помощью метода load( ) класса Loader
			// может SWF-файл или файл изображения (JPG, PNG или GIF).
			// Надо проверять, было ли загружено именно изображение:
			// метод loaderInfo.loader.content as Bitmap вернул объект
			// класса Bitmap или же null, если загрузилось не изображение.
			if ( ( this._Loader.content as Bitmap ) != null )
			{			
				// Должен был загрузиться SWF-файл ресурсов, а не изображение.
				
				// Сообщение об ошибке загрузки файла, не являющегося .swf.
				var errorMessage: String = HillyLandscapeResources
					.LOADED_FILE_IS_NOT_SWF_ERROR_MESSAGE	+ this._Loader.loaderInfo.url;
				trace( errorMessage );
				// Передача события возникновения ошибки при загрузке ресурсов
				// в поток событий, целью - объбектом-получателем - которого
				// является данный экземпляр хранилища ресурсов.
				this.dispatchEvent( new ErrorEvent( HillyLandscapeResources
					.RESOURCES_LOADING_ERROR, false, false, errorMessage ) );
				return;
			} // if ( image != null )
			
			// Класс ApplicationDomain является контейнером для дискретных групп
			// определений классов. Домены приложения используются для разделения
			// классов в одном домене безопасности. Они обеспечивают возможность
			// наличия нескольких определений одного класса и позволяют нижестоящим
			// элементам многократно использовать определения вышестоящих элементов.
			
			// Домены приложений используются, если внешний SWF-файл загружается
			// с помощью класса Loader. Все определения ActionScript 3.0 в загруженном
			// SWF-файле хранятся в домене приложения, который указывается свойством
			// applicationDomain объекта LoaderContext, передаваемого в параметре
			// context объекта load() класса Loader или метода loadBytes().
			// Объект LoaderInfo также содержит свойство applicationDomain,
			// доступное только для чтения.
			
			// Домен приложения загружаемого swf-ресурса.
			var applicationDomain: ApplicationDomain = this._Loader.contentLoaderInfo
				.applicationDomain;
			
			// Для каждой из картинок проверяем, есть ли в домене
			// ресурс с нужным именем, извлекаем класс ресурса-картинки,
			// создаём экземпляр картинки и запоминаем его.
			
			// Получаем все элементы перечисления типов тайлов.
			const TILES_TYPES: Vector.< Enumeration > = Enumeration
				.GetElements( TileType );
			// Просматриваем все типы тайлов, находим соответствующие им
			// названия классов и смещения от цента ячейки; запоминаем
			// объекты извлекаемых классов - графические анные.
			for each ( var tileType: TileType in TILES_TYPES )
			{
				// Информация о текущем тайле.
				var tileInformation: Object = HillyLandscapeResources
					.TILES_INFORMATION[ tileType.Value ];
				this._TilesImages[ tileType ] = new TileImage
					( HillyLandscapeResources.GetResourceBitmapData
						( applicationDomain, tileInformation.ClassName ),
					tileInformation.Offset );
			} // for each
					
			trace( HillyLandscapeResources.RESOURCES_LOADING_COMPLETE_MESSAGE
				+ this._Loader.contentLoaderInfo.url );
			// Передача события успешной загрузки ресурсов в поток событий, целью -
			// объбектом-получателем - которого является данное хранилище ресурсов.
			this.dispatchEvent( new Event( HillyLandscapeResources
				.RESOURCES_LOADING_COMPLETE ) );			
		} // ResourcesLoadingCompleteListener
		
		/** 
		 * Получение объекта как экземпляра класса ресурса.
		 * @param parApplicationDomain Домен приложения загружаемого swf-ресурса.
		 * @param parClassName Имя класса.
		 * @return Полученный экземпляр класса.
		 *
		private static function GetResourceClassObject
			( parApplicationDomain: ApplicationDomain, parClassName: String ): Object
		{
			// Проверяем, есть ли в домене ресурс с нужным именем,
			// извлекаем класс ресурса,
			// создаём экземпляр класса и возвращаем его.		
			if ( parApplicationDomain.hasDefinition( parClassName ) )
			{
				var resourceClass: Class = resourceClass.getDefinition
					( parClassName ) as Class;
				return new resourceClass( );
			} // if	
			return null;
		} // GetResourceClassObject		
		*/
		
		/** 
		 * Получение изображения как экземпляра класса ресурса.
		 * @param parApplicationDomain Домен приложения загружаемого swf-ресурса.
		 * @param parBitmapDataClassName Имя класса изображения.
		 * @return Полученный экземпляр класса изобарежния.
		 */
		private static function GetResourceBitmapData
			( parApplicationDomain: ApplicationDomain,
			parBitmapDataClassName: String ): BitmapData
		{
			// Проверяем, есть ли в домене ресурс с нужным именем,
			// извлекаем класс ресурса,
			// создаём экземпляр класса и возвращаем его.		
			if ( parApplicationDomain.hasDefinition( parBitmapDataClassName ) )
			{
				var resourceClass: Class = parApplicationDomain.getDefinition
					( parBitmapDataClassName ) as Class;
				return new resourceClass( ) as BitmapData;
			} // if	
			return null; 
		} // GetResourceBitmapData
		
		/**
		 * Словарь, для каждого элемента которого ключом является
		 * тип тайла, а значением - информации об изображении:
		 * сам объект BitmapData - графические денные и смещение,
		 * на которое должен смещаться центр изображения
		 * относительно центра его ячейки изометрической сетки.
		 * @return Словарь инфрмации о графических данных тайлов.
		 */		
		public function get TilesImages( ): Dictionary
    { 
        return this._TilesImages;
		}	// get TilesImages			
	}	// HillyLandscapeResources
} // hillyLandscape.resources

