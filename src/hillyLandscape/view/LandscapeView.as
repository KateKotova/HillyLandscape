/**
 * Пакет визуализации игровых объектов.
 */
package hillyLandscape.view
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import geom.CellLocation;
	import geom.IsometricXOYGrid;
	import geom.IsometricParallelToXOYRectangle;
	import geom.IsometricParallelToXOYSquare;
	import hillyLandscape.model.LandscapeModel;
	import hillyLandscape.model.TileType;
	import hillyLandscape.model.TileZLocation;
	import hillyLandscape.model.VerticalFaceType;
	
	/**
	 * Визуальное представление холмистого ландшафта.
	 */	
	public class LandscapeView extends Sprite
	{
		/**
		 * Логическая модель ландшафта.
		 */
		private var _Model: LandscapeModel;
		/**
		 * Отображаемые объекты тайлов.
		 */
		private var _Tiles: Vector.< Vector.< Bitmap > > =
			new Vector.< Vector.< Bitmap > >( );		
		/**
		 * Словарь, для каждого элемента которого ключом является
		 * тип тайла, а значением - информации об изображении:
		 * сам объект BitmapData - графические данные и смещение,
		 * на которое должен смещаться центр изображения
		 * относительно центра его ячейки изометрической сетки.
		 */
		private var _TilesImages: Dictionary = new Dictionary( ); 
		/**
		 * Генератор тайлов. 
		 */		
		private var _TilesGenerator: TilesGenerator;
		
		/**
		 * Индексы строки и столбца ячейки перемещаемого тайла.
		 */
		private var _MovingTileCellLocation: CellLocation = null;
		/**
		 * Последняя заповнившаяся ордината мыши в нажатом состоянии:
		 * предполагается, что кнопка мыши были нажата на одном из тайлов.
		 */
		private var _LastPressedMouseY: Number = 0;
		
		/**
		 * Визуальное представление вертикальных граней, проглядывающих между
		 * тайлами холмистого ландшафта, находящимися на разной высоте.
		 */
		private var _VerticalFaces: VerticalFacesView;		
		
		/**
		 * Конструктор визуального представления холмистого ландшафта.
		 * @param paModel Логическая модель ландшафта.
		 * @param paTilesImages Словарь, для каждого элемента которого
		 * ключом является тип тайла, а значением - информации об изображении:
		 * сам объект BitmapData - графические данные и смещение,
		 * на которое должен смещаться центр изображения
		 * относительно центра его ячейки изометрической сетки.
		 */	
		public function LandscapeView( paModel: LandscapeModel,
			paTilesImages: Dictionary )
		{
			if ( paModel != null )
				this._Model = paModel;
			if ( paTilesImages != null )
				this._TilesImages = paTilesImages;
			// Инициализация генератора тайлов.
			this._TilesGenerator = new TilesGenerator( this._Model.Grid.CellSide );			
			// Визуальное представление вертикальных граней.
			this._VerticalFaces = new VerticalFacesView( this._Model );
			// Установка первоначальных тайлов и вертикальных граней
			// в качестве дочерних элементов отображения.
			this.SetTilesAndVerticalFaces( );
			// Регистрирация объекта-прослушивателя события
			// устновки размещений тайлов на ландшафте.
			this._Model.addEventListener( LandscapeModel.LOCATIONS_ARE_SET,
				this.ModelLocationsAreSetListener );
			// Регистрирация объекта-прослушивателя события нажатия кнопки мыши.
			this.addEventListener( MouseEvent.MOUSE_DOWN, this.MouseDownListener );
		} // LandscapeView
		
		/**
		 * Метод-прослушиватель события устновки размещений тайлов на ландшафте.
		 * @param parEvent Событие.
		 */
		private function ModelLocationsAreSetListener( parEvent: Event ): void
		{		
			// Визуальная установка тайлов и вертикальных граней на ландшафте.
			this.SetTilesAndVerticalFaces( );
		} // ModelLocationsAreSetListener		
		
		/**
		 * Метод установки тайлов и вертикальных граней в пределах данного
		 * объекта-контейнера по существующей матрице размещений тайлов.
		 */
		private function SetTilesAndVerticalFaces( ): void
		{
			// Установка вертикальных граней.
			this._VerticalFaces.SetVerticalFaces( );
			
			// Количество дочерних элементов.
			var childrenCount: int = this.numChildren;
			// Удаление всех потомков.
			for ( var childIndex: int = 0; childIndex < childrenCount; childIndex++ )
				this.removeChildAt( 0 );
				
			// Типы и аппликаты тайлов.
			const TYLES_TYPES_AND_ZS: Vector.< Vector.< TileZLocation > >
				= this._Model.Locations.Locations;
				
			// Тип текущего тайла.
			var tileType: TileType;
			// Периметр текущего тайла.
			var tilePerimeter: IsometricParallelToXOYSquare;
			// Информация об изображении текущего тайла.
			var tileImage: TileImage;
			// Отображаемый объект тайла.
			var tileBitmap: Bitmap;
				
			// Все тайлы будут помещены в данный объект контейнер.
			// Но есть разные планы, задние и передние относительно наблюдателя.
			// Тайлы лучше располагать по клеткам в последовательности, согласно
			// отдалённости от нижнего края сцены, поэтому будет происходить
			// просмотр не по строкам и столбцам клеток изометрической сетки,
			// а по их диагоналям, поторые параллельны нижней части сцены.
			
			// Количество строк матрицы.
			const Y_ROWS_COUNT: uint = this._Model.Locations.YRowsCount;
			// Количество столбцов матрицы матрицы.
			const X_COLUMNS_COUNT: uint = this._Model.Locations.XColumnsCount;			
			// Количество просматриваемых диагоналей.
			const DIAGONALS_COUNT: uint = X_COLUMNS_COUNT + Y_ROWS_COUNT - 1;
			
			// Матрица иображений обнуляется, поэтому её нужно создавать заново.
			this._Tiles = new Vector.< Vector.< Bitmap > >( Y_ROWS_COUNT );			
			for ( var yTileRow: int = 0; yTileRow < Y_ROWS_COUNT; yTileRow++ )
				this._Tiles[ yTileRow ] = new Vector.< Bitmap >( X_COLUMNS_COUNT );			
			
			// По диагоналям, которые расположены горизонтально на сцене,
			// идём сверху вних от верхней точки дома, где находится начало координат.
			for ( var diagonalIndex: int = 0; diagonalIndex < DIAGONALS_COUNT;
					diagonalIndex++ )
				// Проходим текущую диагональ справа-налево: для перехода
				// по клеткам побочной диагонали ордината уменьшается,
				// а абсцисса растёт.
				for ( var yRow: int = Math.min( diagonalIndex, Y_ROWS_COUNT - 1 ),
						xColumn: int = diagonalIndex - yRow;
						( yRow >= 0 ) && ( xColumn < X_COLUMNS_COUNT );
						yRow--, xColumn++ )					
				{
					// Тип текущего тайла.
					tileType = TYLES_TYPES_AND_ZS[ yRow ][ xColumn ].Type;
					// Периметр текущего тайла.
					tilePerimeter	= this._Model.IsometricLocations[ yRow ][ xColumn ];
					// Информация об изображении текущего тайла.
					tileImage = this._TilesImages[ tileType ];
					// Генератор изображений генерирует отображаемый объект,
					// и он помещается в качестве дочернего элемента.
					tileBitmap = this._TilesGenerator.GenerateBitmap
						( tileImage, tilePerimeter );
					this._Tiles[ yRow ][ xColumn ] = tileBitmap;
					this.addChild( tileBitmap );
					
					this.addChild( this._VerticalFaces.Faces
						[ VerticalFaceType.XOZ_PARALLEL.Value ][ yRow ][ xColumn ] );
					this.addChild( this._VerticalFaces.Faces
						[ VerticalFaceType.YOZ_PARALLEL.Value ][ yRow ][ xColumn ] );					
				} // for-for		
		} // SetTilesAndVerticalFaces
		
		/**
		 * Метод-прослушиватель события нажатия кнопки мыши.
		 * @param parMouseEvent Событие мыши.
		 */
		private function MouseDownListener( parMouseEvent: MouseEvent ): void
		{
			// Если была нажата не основная кнопка мыши,
			// то реации на событие мыши не будет.
			if ( ! parMouseEvent.buttonDown )
				return;
				
			// Определяется, на каком тайле произошёл клик мыши.
			// Индексы строки и столбца ячейки тайла, по которому был произведён клик.
			this._MovingTileCellLocation = this._Model.GetCellLocationIfContains
				( new Point( parMouseEvent.localX, parMouseEvent.localY ) );
			// Если клик не был произведён ни по одному из тайлов.
			if ( this._MovingTileCellLocation == null )
				return;
				
			// Запоминается ордината точки объекта контейнера, в которой
			// была нажата кнопка мыши.
			this._LastPressedMouseY = parMouseEvent.localY;
			
			// Регистрирация объекта-прослушивателя события перемещения курсора мыши.
			this.stage.addEventListener( MouseEvent.MOUSE_MOVE,
				this.MouseMoveListener );
			// Регистрирация объекта-прослушивателя отпускания кнопки мыши.
			this.stage.addEventListener( MouseEvent.MOUSE_UP,	this.MouseUpListener );
		} // MouseDownListener
		
		/**
		 * Метод-прослушиватель события перемещения курсора мыши.
		 * @param parMouseEvent Событие мыши.
		 */
		private function MouseMoveListener( parMouseEvent: MouseEvent ): void
		{
			// Смещение курсора мыши по оси ординат от точки нажатия
			// основной кнопки мыши в процессе управления движением мышью.
			var mouseMoveYOffset: Number = parMouseEvent.localY -
				this._LastPressedMouseY;
			// Запоминается последняя ордината точки объекта-контейнера,
			// в которой мышь находилась в нажатом состоянии.
			this._LastPressedMouseY = parMouseEvent.localY;
			
			// Перемещение тайла с сохранёнными индексами по оси аппликат,
			// которое должно произойти.
			var tileZOffset: Number = -mouseMoveYOffset;
			// Перемещение тайла с сохранённым индексами матрицы по оси аппликат.
			// Возвращается реальное смещение, которое произошло для данного тайла
			// по оси OZ: заданы предельные границы значения высоты расположения
			// тайла по оси OZ, нарушать которые нельзя.
			tileZOffset = this._Model.MoveZ
				( this._MovingTileCellLocation.YRow,
				this._MovingTileCellLocation.XColumn, tileZOffset );
			// Перемещаемый тайл.
			this._Tiles[ this._MovingTileCellLocation.YRow ]
				[ this._MovingTileCellLocation.XColumn ].y -=tileZOffset;
		} // MouseMoveListener
		
		/**
		 * Метод-прослушиватель события отпускания кнопки мыши.
		 * @param parMouseEvent Событие мыши.
		 */
		private function MouseUpListener( parMouseEvent: MouseEvent ): void
		{
			// Отмена регистрирации объекта-прослушивателя события
			// перемещения курсора мыши.
			this.stage.removeEventListener( MouseEvent.MOUSE_MOVE,
				this.MouseMoveListener );
			// Отмена регистрирации объекта-прослушивателя события
			// отпускания кнопки мыши.
			this.stage.removeEventListener( MouseEvent.MOUSE_UP,
				this.MouseUpListener );
		} // MouseUpListener
			
		/**
		 * Логическая модель ландшафта.
		 * @return Логическая модель ландшафта.
		 */		
		public function get Model( ): LandscapeModel
    { 
    	return this._Model;
		}	// get Model
		
		/**
		 * Отображаемые объекты тайлов.
		 * @return Отображаемые объекты тайлов.
		 */		
		public function get Tiles( ): Vector.< Vector.< Bitmap > >
    { 
    	return this._Tiles;
		}	// get Tiles
	} // LandscapeView
} // hillyLandscape.view
