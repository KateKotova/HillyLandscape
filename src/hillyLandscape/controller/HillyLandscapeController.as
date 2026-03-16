/**
 * Пакет контроллеров игровых объектов.
 */
package hillyLandscape.controller
{	
	import flash.display.BlendMode;
	import flash.display.CapsStyle;
	import flash.display.DisplayObjectContainer;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import hillyLandscape.resources.HillyLandscapeResources;
	import geom.IsometricXOYGrid;
	import hillyLandscape.model.LandscapeModel;
	import hillyLandscape.model.TileEvent;
	import hillyLandscape.view.LandscapeView;

	/**
	 * Класс контроллера ландшафта переменной высоты.
	 */ 
	public final class HillyLandscapeController
	{
		/**
		 * Управление ресурсами.
		 */ 		
		private var _Resources: HillyLandscapeResources
			= new HillyLandscapeResources( );
		/**
		 * Контейнер, в который будут добавляться изображения.
		 * Все координаты рассчитываются к его локальной системе координат.
		 */
		private var _Container: DisplayObjectContainer = new Sprite( );
		/**
		 * Текст по умолчанию в метках, связанных с координатами тайла.
		 */
		private static const TILE_LOCATION_LABELS_DEFAULT_TEXT: String = "*";
		/**
		 * Метка с координатой строки по оси OY текущего перемещающегося тайла.
		 */	
		private var _TextFieldTileYRow: TextField = new TextField( );
		/**
		 * Метка с координатой столбцы по оси OX текущего перемещающегося тайла.
		 */	
		private var _TextFieldTileXColumn: TextField = new TextField( );
		/**
		 * Метка с координатой по оси OZ высоты текущего перемещающегося тайла.
		 */	
		private var _TextFieldTileZHeight: TextField = new TextField( );
		/**
		 * Кнопка открытия файла.
		 */	
		private var _TextFieldLoadFile: TextField = new TextField( );
		/**
		 * Кнопка сохранения файла.
		 */	
		private var _TextFieldSaveFile: TextField = new TextField( );		
		
		/**
		 * Изометрическая сетка, параллельная плоскости XOY,
		 *  представляющая собой локальную систему координат -
		 * локальную плоскость XOY.
		 * В стандартной ортогональной изометрической проекции начало координат -
		 * в центре. Аксонометрические оси образуют между собой углы в 120 градусов.
		 * Ось аппликат направлена снизу вверх, поэтому все вертикально направленные
		 * линии параллельны ей.
		 * Ось абсцисс от начала координат направлена влево-вниз, поэтому линии,
		 * параллельные ей имеют направление слева-снизу вправо-вверх и наоборот.
		 * Ось ординат от начала координат направлена врпво-вниз, поэтому линии,
		 * параллельные ей имеют направление справа-снизу влево-вверх и наоборот.
		 * Данная сетка представляет собой разделение плоскости XOY
		 * на одинаковые изометрические ромбы.
		 */			
		private var _IsometricXOYGrid: IsometricXOYGrid = new IsometricXOYGrid( 35 );
		/**
		 * Изометрическое начало координат - коорданиты самого верхнего угла
		 * самого верхнего квадратика из тех, на которые делится координатная
		 * плоскость XOY холмистого ландшафта.
		 * Помним, что это не самая высокая точка, как таковая:
		 * если передвигать тайлы, они могут оказаться выше, чем эта точка,
		 * приландлежащая координатной плоскости XOY.
		 */
		public static const ISOMETRIC_ORIGIN: Point = new Point( 310, 160 );
		
		/**
		 * Логическое представление холмистого ландшафта.
		 */
		private var _LandscapeModel: LandscapeModel;
		/**
		 * Визуальное представление холмистого ландшафта.		
		 */
		private var _LandscapeView: LandscapeView;
		
		/**
		 * Конструктор контроллера ландшафта переменной высоты.
		 * @param parСontainer Контейнер, в который будут добавляться изображения.
		 * Все координаты рассчитываются к его локальной системе координат.
		 */		
		public function HillyLandscapeController
			( parСontainer: DisplayObjectContainer = null )
		{
			if ( parСontainer != null )
				this._Container = parСontainer;
			this.InitializeСontainerComponents( );
			// Загрузка ресурсов и ожидание результатов при любом исходе загрузки.
			this._Resources.Load( );
			this._Resources.addEventListener( HillyLandscapeResources
				.RESOURCES_LOADING_COMPLETE, this.ResourcesLoadingCompleteListener );
			this._Resources.addEventListener( HillyLandscapeResources
				.RESOURCES_LOADING_ERROR, this.ResourcesLoadingCompleteListener );		
		} // HillyLandscapeController
		
		/**
		 * Метод инициализации элементов управления на форме.
		 */
		private function InitializeСontainerComponents( ): void
		{
			const TITLE_LABELS_X: Number = 8.25;
			const LABELS_HEIGHT: Number = 30;
			const OFFSET: Number = 5;
			
			var textFieldsTileTitles: Vector.< TextField > = new Vector.< TextField >( );
			
			var textFieldMovingTileTitle: TextField = new TextField( );
			textFieldMovingTileTitle.text
				= "Текущий тайл, для которого меняется высота:";
			textFieldMovingTileTitle.y = 8.35;
			textFieldMovingTileTitle.width = 150;
			textFieldsTileTitles.push( textFieldMovingTileTitle );
			
			var textFieldTileYRowTitle: TextField = new TextField( );
			textFieldTileYRowTitle.text
				= "Индекс строки по оси OY:";
			textFieldTileYRowTitle.width = 80;
			textFieldsTileTitles.push( textFieldTileYRowTitle );
			
			var textFieldTileXColumnTitle: TextField = new TextField( );
			textFieldTileXColumnTitle.text
				= "Индекс стобца по оси OX:";
			textFieldTileXColumnTitle.width = 90;
			textFieldsTileTitles.push( textFieldTileXColumnTitle );
			
			var textFieldTileZHeightTitle: TextField = new TextField( );
			textFieldTileZHeightTitle.text
				= "Текущая высота:";
			textFieldTileZHeightTitle.width = 90;
			textFieldsTileTitles.push( textFieldTileZHeightTitle );
			
			var componentIndex: uint;
			var currentTextField: TextField;
			for ( componentIndex = 0; componentIndex < textFieldsTileTitles.length;
				componentIndex++ )
			{
				currentTextField = TextField( textFieldsTileTitles[ componentIndex ] );
				if ( componentIndex > 0 )
					currentTextField.y
						= TextField( textFieldsTileTitles[ componentIndex - 1 ] ).y
						+ LABELS_HEIGHT + OFFSET;				
				currentTextField.x = TITLE_LABELS_X;			
				currentTextField.height = LABELS_HEIGHT;
				currentTextField.wordWrap = true;
				currentTextField.autoSize = TextFieldAutoSize.LEFT;
				currentTextField.blendMode = BlendMode.INVERT;
				this._Container.addChild( currentTextField );
			} // for
			
			const TILE_LOCATION_LABELS_X: Number = 98;
			const TILE_LOCATION_LABELS_WIDTH: Number = 100;
			
			var textFieldsTileLocations: Vector.< TextField > = new Vector.< TextField >( );		
			
			this._TextFieldTileYRow.y = TextField( textFieldsTileTitles[ 1 ] ).y;
			textFieldsTileLocations.push( this._TextFieldTileYRow );
			textFieldsTileLocations.push( this._TextFieldTileXColumn );
			textFieldsTileLocations.push( this._TextFieldTileZHeight );
			
			for ( componentIndex = 0; componentIndex < textFieldsTileLocations.length;
				componentIndex++ )
			{
				currentTextField = TextField( textFieldsTileLocations[ componentIndex ] );
				if ( componentIndex > 0 )
					currentTextField.y
						= TextField( textFieldsTileLocations[ componentIndex - 1 ] ).y
						+ LABELS_HEIGHT + OFFSET;				
				currentTextField.x = TILE_LOCATION_LABELS_X;	
				currentTextField.width = TILE_LOCATION_LABELS_WIDTH;
				currentTextField.height = LABELS_HEIGHT;
				currentTextField.text = HillyLandscapeController
					.TILE_LOCATION_LABELS_DEFAULT_TEXT;
				currentTextField.wordWrap = false;
				currentTextField.autoSize = TextFieldAutoSize.LEFT;
				currentTextField.blendMode = BlendMode.INVERT;
				this._Container.addChild( currentTextField );
			} // for
	
			this._TextFieldLoadFile.x = 360;
			this._TextFieldLoadFile.y = 12;
			this._TextFieldLoadFile.width = 135;
			this._TextFieldLoadFile.height = 20;
			this._TextFieldLoadFile.text = "Открыть набор высот";
			this._TextFieldLoadFile.addEventListener( MouseEvent.CLICK,
				this.TextFieldLoadFileClickListener );	
			this._Container.addChild( this._TextFieldLoadFile );
			
			this._TextFieldSaveFile.x = this._TextFieldLoadFile.x;
			this._TextFieldSaveFile.y = this._TextFieldLoadFile.y
				+ this._TextFieldLoadFile.height + 2.5 * OFFSET;
			this._TextFieldSaveFile.width = this._TextFieldLoadFile.width;
			this._TextFieldSaveFile.height = this._TextFieldLoadFile.height;
			this._TextFieldSaveFile.text = "Сохранить набор высот";
			this._TextFieldSaveFile.addEventListener( MouseEvent.CLICK,
				this.TextFieldSaveFileClickListener );	
			this._Container.addChild( this._TextFieldSaveFile );

			var loadFileShape: Shape = this.GetButtonShape( );
			loadFileShape.x = this._TextFieldLoadFile.x - OFFSET;
			loadFileShape.y = this._TextFieldLoadFile.y;
			loadFileShape.addEventListener( MouseEvent.CLICK,
				this.TextFieldLoadFileClickListener );
			this._Container.addChild( loadFileShape );

			var saveFileShape: Shape = this.GetButtonShape( );
			saveFileShape.x = this._TextFieldSaveFile.x - OFFSET;
			saveFileShape.y = this._TextFieldSaveFile.y;
			saveFileShape.addEventListener( MouseEvent.CLICK,
				this.TextFieldLoadFileClickListener );
			this._Container.addChild( saveFileShape );
		} // InitializeСontainerComponents

		/**
		 * Метод, возвращающий нечто похожее на кнопку.
		 */
		private function GetButtonShape( ): Shape
		{
			// Форма для отрисовки.
			var shape: Shape = new Shape( );
			shape.graphics.lineStyle( 2, 0x00000000, 1, false, LineScaleMode.VERTICAL,
				CapsStyle.NONE, JointStyle.MITER, 3 );
			shape.graphics.beginFill( 0xAA034422 );
			shape.graphics.moveTo( 0, 0 );
			shape.graphics.lineTo( this._TextFieldSaveFile.width, 0 );
			shape.graphics.lineTo( this._TextFieldSaveFile.width,
				this._TextFieldSaveFile.height );
			shape.graphics.lineTo( 0, this._TextFieldSaveFile.height );
			shape.graphics.lineTo( 0, 0 );
			shape.graphics.endFill( );
			shape.cacheAsBitmap = true;
			shape.alpha = 0.3;
			shape.x = 0;
			shape.y = 0;
			return shape;
		} // Shape

		/**
		 * Метод-прослушиватель события завершения загрузки ресурсов.
		 * @param parEvent Событие.
		 */
		private function ResourcesLoadingCompleteListener( parEvent: Event )
			: void
		{
			// Инициализация вьюверов и моделей.
			this.InitializeModelsAndViews( );
		} // ResourcesLoadingCompleteListener
		
		/**
		 * Метод инициализации моделей и вьюверов.
		 */
		private function InitializeModelsAndViews( ): void
		{
			// Логическое представление холмистого ландшафта.
			this._LandscapeModel = new LandscapeModel( HillyLandscapeController
				.ISOMETRIC_ORIGIN, this._IsometricXOYGrid );
			// Визуальное представление холмистого ландшафта.	
			this._LandscapeView = new LandscapeView( this._LandscapeModel,
				this._Resources.TilesImages );
			// Добавление граней и тайлов ландшафта.
			this._Container.addChild( this._LandscapeView );
			
			// Регистрирация объекта-прослушивателя события
			// перемещения тайла по оси OZ.
			this._LandscapeModel.addEventListener( TileEvent.TILE_Z_MOVEMENT,
				this.TileZMovementListener );	
			// Регистрирация объекта-прослушивателя отпускания кнопки мыши:
			// схитрим: если мышь отпустили, то до этого её кнопка была стопроцентно
			// нажата, вероятнее всего, клик ыл по тайлу, и его координаты изменения
			// отображались. Когди кнопка отжата, то нечего сообщать о тайлах,
			// потому что ни один из них гарантированно не перемещается.
			this._Container.stage.addEventListener( MouseEvent.MOUSE_UP,
				this.MouseUpListener );			
		} // InitializeModelsAndViews		
		
		/**
		 * Метод-прослушиватель события клика мыши на кнопке открытия файла.
		 * @param parEvent Событие.
		 */
		private function TextFieldLoadFileClickListener( parEvent: Event ): void
		{
			this._LandscapeView.Model.Locations.LoadFromUserSelectedFile( );			
		} // TextFieldLoadFileClickListener
		
		/**
		 * Метод-прослушиватель события клика мыши на кнопке сохранения файла.
		 * @param parEvent Событие.
		 */
		private function TextFieldSaveFileClickListener( parEvent: Event ): void
		{
			this._LandscapeView.Model.Locations.SaveToXMLFile( );			
		} // TextFieldSaveFileClickListener		
		
		/**
		 * Метод-прослушиватель события перемещения тайла по оси OZ.
		 * @param parTileEvent Событие тайла.
		 */
		private function TileZMovementListener( parTileEvent: TileEvent ): void
		{
			this._TextFieldTileYRow.text = parTileEvent.YRow.toString( ); 
			this._TextFieldTileXColumn.text = parTileEvent.XColumn.toString( );  
			this._TextFieldTileZHeight.text = parTileEvent.ZHeight.toString( ); 
		} // TileZMovementListener
		
		/**
		 * Метод-прослушиватель события отпускания кнопки мыши.
		 * @param parMouseEvent Событие мыши.
		 */
		private function MouseUpListener( parMouseEvent: MouseEvent ): void
		{
			this._TextFieldTileYRow.text = HillyLandscapeController
				.TILE_LOCATION_LABELS_DEFAULT_TEXT;
			this._TextFieldTileXColumn.text = HillyLandscapeController
				.TILE_LOCATION_LABELS_DEFAULT_TEXT;
			this._TextFieldTileZHeight.text = HillyLandscapeController
				.TILE_LOCATION_LABELS_DEFAULT_TEXT;
		} // MouseUpListener
	} // HillyLandscapeController	
} // hillyLandscape.controller
