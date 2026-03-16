/**
 * Пакет визуальных представлений игровых объектов.
 */
package hillyLandscape.view
{
	import flash.display.CapsStyle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;  
	import flash.display.SpreadMethod;
	/*import flash.display.Sprite;*/
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import geom.CellLocation;
	import geom.IsometricParallelToXOYSquare;
	import hillyLandscape.model.LandscapeModel;
	import hillyLandscape.model.TileEvent;
	import hillyLandscape.model.TilesLocations;
	import hillyLandscape.model.VerticalFaceType;

	/**
	 * Визуальное представление вертикальных граней, проглядывающих между
	 * тайлами холмистого ландшафта, находящимися на разной высоте.
	 * В стандартной ортогональной изометрической проекции начало координат -
	 * в центре. Аксонометрические оси образуют между собой углы в 120 градусов.
	 * Ось аппликат направлена снизу вверх, поэтому все вертикально направленные
	 * линии параллельны ей.
	 * Ось абсцисс от начала координат направлена влево-вниз, поэтому линии,
	 * параллельные ей имеют направление слева-снизу вправо-вверх и наоборот.
	 * Ось ординат от начала координат направлена враво-вниз, поэтому линии,
	 * параллельные ей имеют направление справа-снизу влево-вверх и наоборот.
	 * Каждый тайл располагается в плоскости параллельно плоскости XOY.
	 * Вначале любой тайл, находится в координатной плоскости XOY,
	 * разделённой сеткой. Одну ячейку кординатной сети занимает один тайл.
	 * Ячейки сетки пронумерованы целочисленными индексами от нуля.
	 * Два индекса соответствуют положению тайла в строке по оси OY
	 * и в столбце по оси OX. Самый первый тайл имеет координаты ячейки [0,0].
	 * Положение тайлов может изменяться по высоте. Их координаты и индексы
	 * по осям OX и OY при этом не изменяются. Тогда, если соединить
	 * смежные тайлы, будут видны вертикальные грани, параллельные
	 * координатным плоскостям YOZ и XOZ.
	 * Грани, параллельные YOZ, возникают между тайлами в соседних столбцах,
	 * расположенных в ячейках по оси OX (ось направлена от цента влево-вниз).
	 * Грани, параллельные XOZ, возникают между тайлами в соседних строках,
	 * расположенных в ячейках по оси OY (ось направлена от цента вправо-вниз).
	 * Количество вертикальных граней между смежными тайлами в каждом ряду
	 * на единицу меньше, чем само количество ячеек в этом ряду.
	 */
	public class VerticalFacesView /*extends Sprite*/
	{
		/**
		 * Ассоциативный массив, ключи которого - типы граней,
		 * значения - объекты, храняющие информацию об цветах граней.
		 */
		public static const COLORS: Object =
		{
			// Грань, параллельная XOZ.
			XOZ_PARALLEL:
			{
				// Цвет минимальной точки грани.
				ZMinimumFillColor: 0x240055,
				// Цвет максимальной точки грани.
				ZMaximumFillColor: 0xFFBE74
			}, // XOZ_PARALLEL
			// Грань, параллельная YOZ.
			YOZ_PARALLEL:
			{
				// Цвет минимальной точки грани.
				ZMinimumFillColor: 0x004416,
				// Цвет максимальной точки грани.
				ZMaximumFillColor: 0xFFAEAA
			} // YOZ_PARALLEL
		}; // COLORS
		
		/**
		 * Доступный диапазон изменения высоты тайла.
		 */		
		private static const TILE_Z_HEIGHT_RANGE: Number
			= TilesLocations.MAXIMUM_Z_HEIGHT
			- TilesLocations.MINIMUM_Z_HEIGHT + 1;		

		/**
		 * Приращение цвета, приходящееся на 1 пиксель
		 * для вертикальной грани, параллельной плоскости XOZ.
		 */
		private static const XOZ_PARALLEL_VERTICAL_FACE_COLOR_INCREMENT: uint
			= Math.round( Number
			( VerticalFacesView.COLORS[ VerticalFaceType.XOZ_PARALLEL.Value ]
				.ZMaximumFillColor
			- VerticalFacesView.COLORS[ VerticalFaceType.XOZ_PARALLEL.Value ]
				.ZMinimumFillColor )
			/ VerticalFacesView.TILE_Z_HEIGHT_RANGE );
		/**
		 * Приращение цвета, приходящееся на 1 пиксель
		 * для вертикальной грани, параллельной плоскости YOZ.
		 */
		private static const YOZ_PARALLEL_VERTICAL_FACE_COLOR_INCREMENT: uint
			= Math.round( Number
			( VerticalFacesView.COLORS[ VerticalFaceType.YOZ_PARALLEL.Value ]
				.ZMaximumFillColor
			- VerticalFacesView.COLORS[ VerticalFaceType.YOZ_PARALLEL.Value ]
				.ZMinimumFillColor )
			/ VerticalFacesView.TILE_Z_HEIGHT_RANGE );
			
		/**
		 * Ассоциативный массив, ключи которого - типы граней,
		 * значения - приращения цетов для граней.
		 */
		public static const COLORS_INCREMENT: Object =
		{
			// Грань, параллельная XOZ.
			XOZ_PARALLEL: VerticalFacesView
				.XOZ_PARALLEL_VERTICAL_FACE_COLOR_INCREMENT,
			// Грань, параллельная YOZ.
			YOZ_PARALLEL: VerticalFacesView
				.YOZ_PARALLEL_VERTICAL_FACE_COLOR_INCREMENT
		}; // COLORS_INCREMENT
			
		/**
		 * Толщина линии обводки.
		 */
		public static const LINE_THICKNESS: Number = 3;
		/**
		 * Цвет линии обводки.
		 */
		public static const LINE_COLOR: uint = 0x00000000;
		/**
		 * Предел обрезки скоса угла линии обводки.
		 */
		public static const LINE_MITER_LIMIT: Number = 5;	
		/**
		 * Смещение формы рисования грани - получается из-за того,
		 * что линия обводки имеет толщину, надо смещать форму для отцентровки.
		 */
		public static const SHAPE_OFFSET: Point = new Point
			( 0.7 * VerticalFacesView.LINE_THICKNESS - 1,
			1.2 * VerticalFacesView.LINE_THICKNESS - 1 ); 
		
		/**
		 * Логическая модель ландшафта, состоящего из тайлов.
		 */
		private var _LandscapeModel: LandscapeModel;
			
		/**
		 * Ассоциативный массив, ключи которого - типы граней,
		 * значения - матрицы отображаемых объектов граней.
		 */
		private var _Faces: Object =
		{
			// Грань, параллельная XOZ.
			XOZ_PARALLEL: new Vector.< Vector.< Bitmap > >( ),
			// Грань, параллельная YOZ.
			YOZ_PARALLEL: new Vector.< Vector.< Bitmap > >( )
		}; // _Faces
		
		/**
		 * Конструктор логического представление вертикальных граней,
		 * проглядывающих между тайлами холмистого ландшафта, находящимися
		 * на разной высоте.
		 * @param parLandscapeModel Логическая модель ландшафта.
		 */	
		public function VerticalFacesView( parLandscapeModel: LandscapeModel )
		{
			if ( parLandscapeModel != null )
				this._LandscapeModel = parLandscapeModel;
			/*// Установка первоначальных вертикальных граней
			// в качестве дочерних элементов отображения.
			this.SetVerticalFaces( );*/
			/*// Регистрирация объекта-прослушивателя события
			// устновки размещений тайлов на ландшафте.
			this._LandscapeModel.addEventListener( LandscapeModel.LOCATIONS_ARE_SET,
				this.LandscapeModelLocationsAreSetListener );*/
			// Регистрирация объекта-прослушивателя события
			// перемещения тайла по оси OZ.
			this._LandscapeModel.addEventListener( TileEvent.TILE_Z_MOVEMENT,
				this.LandscapeModelTileZMovementListener );
		} // VerticalFacesView
		
		/**
		 * Метод-прослушиватель события события перемещения тайла по оси OZ.
		 * @param parTileEvent Событие тайла.
		 */
		private function LandscapeModelTileZMovementListener
			( parTileEvent: TileEvent ): void
		{		
			// Визуальная установка вертикальных граней для перемещённой ячейки.
			this.SetVerticalFaceAfterTile( VerticalFaceType.XOZ_PARALLEL,
				parTileEvent.YRow, parTileEvent.XColumn );
			this.SetVerticalFaceAfterTile( VerticalFaceType.YOZ_PARALLEL,
				parTileEvent.YRow, parTileEvent.XColumn );
				
			// Также смотрим грани перед ней.	
			if ( parTileEvent.YRow > 0 )
				this.SetVerticalFaceAfterTile( VerticalFaceType.XOZ_PARALLEL,
					parTileEvent.YRow - 1, parTileEvent.XColumn );
			if ( parTileEvent.XColumn > 0 )
				this.SetVerticalFaceAfterTile( VerticalFaceType.YOZ_PARALLEL,
					parTileEvent.YRow, parTileEvent.XColumn - 1 );
		} // LandscapeModelTileZMovementListener
		
		/**
		 * Метод-прослушиватель события устновки размещений тайлов на ландшафте.
		 * @param parEvent Событие.
		 *
		private function LandscapeModelLocationsAreSetListener
			( parEvent: Event ): void
		{		
			// Визуальная установка вертикальных граней.
			this.SetVerticalFaces( );
		} // LandscapeModelLocationsAreSetListener*/	
		
		/**
		 * Метод установки вертикальных граней.
		 */
		public function SetVerticalFaces( ): void
		{
			/*// Количество дочерних элементов.
			var childrenCount = this.numChildren;			
			// Удаление всех потомков.
			for ( var childIndex: int = 0; childIndex < childrenCount; childIndex++ )
				this.removeChildAt( 0 );*/
				
			// Количество строк матрицы тайлов.
			const Y_ROWS_COUNT: uint = this._LandscapeModel.Locations.YRowsCount;
			// Количество столбцов матрицы матрицы.
			const X_COLUMNS_COUNT: uint = this._LandscapeModel.Locations.XColumnsCount;			
			// Количество просматриваемых диагоналей.
			const DIAGONALS_COUNT: uint = X_COLUMNS_COUNT + Y_ROWS_COUNT - 1;
			
			if ( Y_ROWS_COUNT < 1 )
				this._Faces[ VerticalFaceType.XOZ_PARALLEL.Value ].length = 0;
			if ( X_COLUMNS_COUNT < 1 )
			{
				this._Faces[ VerticalFaceType.YOZ_PARALLEL.Value ].length = 0;
				if ( Y_ROWS_COUNT < 1 )
					return;
			} // if			
			
			// Матрицы иображений обнуляются, поэтому их нужно создавать заново.
			this._Faces[ VerticalFaceType.XOZ_PARALLEL.Value ]
				= new Vector.< Vector.< Bitmap > >( Y_ROWS_COUNT );	
			this._Faces[ VerticalFaceType.YOZ_PARALLEL.Value ]
				= new Vector.< Vector.< Bitmap > >( Y_ROWS_COUNT );
			for ( var yTileRow: int = 0; yTileRow < Y_ROWS_COUNT; yTileRow++ )
			{
				this._Faces[ VerticalFaceType.XOZ_PARALLEL.Value ][ yTileRow ]
					= new Vector.< Bitmap >( X_COLUMNS_COUNT );	
				this._Faces[ VerticalFaceType.YOZ_PARALLEL.Value ][ yTileRow ]
					= new Vector.< Bitmap >( X_COLUMNS_COUNT );
			} // for
			
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
					// Установки вертикальных граней, идущих после указанного тайла.
					
					this._Faces[ VerticalFaceType.XOZ_PARALLEL.Value ]
						[ yRow ][ xColumn ] = new Bitmap( );
					this.SetVerticalFaceAfterTile( VerticalFaceType.XOZ_PARALLEL,
						yRow, xColumn );
					/*this.addChild( this._Faces[ VerticalFaceType
						.XOZ_PARALLEL.Value ][ yRow ][ xColumn ] );*/
					
					this._Faces[ VerticalFaceType.YOZ_PARALLEL.Value ]
						[ yRow ][ xColumn ] = new Bitmap( );					
					this.SetVerticalFaceAfterTile( VerticalFaceType.YOZ_PARALLEL,
						yRow, xColumn );					
					/*this.addChild( this._Faces[ VerticalFaceType
						.YOZ_PARALLEL.Value ][ yRow ][ xColumn ] );*/						
				} // for-for
		} // SetVerticalFaces
		
		/**
		 * Метод получения индексов тайла, идущего после указанного тайла
		 * и имеющего с заданным тайлом общую грань заданного типа.
		 * @param parVerticalFaceType Типа вертикальной грани.
		 * @param parTileYRow Индекс строки размещения ячейки тайла по оси OY.
		 * @param parTileXColumn Индекс столбца размещения ячейки тайла по оси OX.
		 * @return Тайл, идущий вслед за заданным.
		 */
		private function GetNextTileCellLocation
		(
			parVerticalFaceType: VerticalFaceType,
			parTileYRow: uint,
			parTileXColumn: uint			
		) : CellLocation
		{
			// Ячейка следующего тайла, между которым и заданным тайлом
			// образуется вертикальная грань.
			var nextTileCellLocation: CellLocation = new CellLocation
				( parTileYRow, parTileXColumn );
			switch ( parVerticalFaceType )
			{
				// Грань, параллельная XOZ. Такие грани возникают между тайлами
				// в соседних строках, расположенных в ячейках по оси OY
				// (ось направлена от цента вправо-вниз).
				case VerticalFaceType.XOZ_PARALLEL:
					nextTileCellLocation.YRow++;
					// Если такой грани уже нет.
					if ( nextTileCellLocation.YRow
							> this._LandscapeModel.Locations.YRowsCount - 1 )
						return null;
					break;
					
				// Грань, параллельная YOZ. Такие грани возникают между тайлами
				// в соседних столбцах, расположенных в ячейках по оси OX
				// (ось направлена от цента влево-вниз).
				case VerticalFaceType.YOZ_PARALLEL:
					nextTileCellLocation.XColumn++;
					// Если такой грани уже нет.
					if ( nextTileCellLocation.XColumn
							> this._LandscapeModel.Locations.XColumnsCount - 1 )
						return null;
					break;
			} // switch ( parVerticalFaceType )
			
			return nextTileCellLocation;
		} // GetNextTileCellLocation
		
		/**
		 * Метод установки вертикальной грани, идущей после указанного тайла.
		 * @param parVerticalFaceType Типа вертикальной грани.
		 * @param parTileYRow Индекс строки размещения ячейки тайла по оси OY.
		 * @param parTileXColumn Индекс столбца размещения ячейки тайла по оси OX.
		 */
		private function SetVerticalFaceAfterTile
		(
			parVerticalFaceType: VerticalFaceType,
			parTileYRow: uint,
			parTileXColumn: uint			
		) : void
		{
			// Ячейка следующего тайла, между которым и заданным тайлом
			// образуется вертикальная грань.
			var nextTileCellLocation: CellLocation = this.GetNextTileCellLocation
				(	parVerticalFaceType, parTileYRow, parTileXColumn );
			
			// Высота данного тайла по оси OZ.
			const THIS_TILE_Z_HEIGHT: Number = this._LandscapeModel.Locations
				.Locations[ parTileYRow ][ parTileXColumn ].Z;
			// Высота следующего тайла по оси OZ.
			// Если данный тайл - последний, то грань всё равно надо рисовать
			// и предполагается, что, если бы за данным тайлом шёл ещё один,
			// его высота оказалась бы нулевой.
			// То есть одно из рёбер полученной грани будет желать в плоскости XOY.
			const NEXT_TILE_Z_HEIGHT: Number = ( nextTileCellLocation == null )
				? 0 : this._LandscapeModel.Locations.Locations
				[ nextTileCellLocation.YRow ][ nextTileCellLocation.XColumn ].Z;
			
			// Изображение данной грани.
			var thisVerticalFace: Bitmap = this._Faces
				[ parVerticalFaceType.Value ][ parTileYRow ][ parTileXColumn ];
			// Если следующий тайл оказался выше заданного,
			// эта грань не будет видна.
			if ( NEXT_TILE_Z_HEIGHT >= THIS_TILE_Z_HEIGHT )
			{
				thisVerticalFace.alpha = 0;
				return;
			} // if ( NEXT_TILE_Z_HEIGHT > THIS_TILE_Z_HEIGHT )
			
			// Цвет низа параллелограмма ветрикальной грани.
			const BOTTOM_COLOR: uint = VerticalFacesView.COLORS
				[ parVerticalFaceType.Value ].ZMinimumFillColor
				+ VerticalFacesView.COLORS_INCREMENT[ parVerticalFaceType.Value ]
				* ( TilesLocations.MAXIMUM_Z_HEIGHT - NEXT_TILE_Z_HEIGHT + 1 );
			// Цвет верха параллелограмма ветрикальной грани.
			const TOP_COLOR: uint = VerticalFacesView.COLORS
				[ parVerticalFaceType.Value ].ZMinimumFillColor
				+ VerticalFacesView.COLORS_INCREMENT[ parVerticalFaceType.Value ]
				* ( TilesLocations.MAXIMUM_Z_HEIGHT - THIS_TILE_Z_HEIGHT + 1 );				
			
			// У грани 2 верхние точки - это нижняя и правая/левая данного тайла
			// и 2 нижние точки - это верхняя и левая/правая следующего тайла.
			
			// Первая верхняя точки грани.
			var top1: Point;
			// Вторая верхняя точки грани.
			var top2: Point;
			
			// Периметр данного тайла.
			const THIS_TILE_PERIMETER: IsometricParallelToXOYSquare
				= this._LandscapeModel.IsometricLocations
				[ parTileYRow ][ parTileXColumn ];
			
			switch ( parVerticalFaceType )
			{
				// Грань, параллельная XOZ. Такие грани возникают между тайлами
				// в соседних строках, расположенных в ячейках по оси OY
				// (ось направлена от цента вправо-вниз).
				case VerticalFaceType.XOZ_PARALLEL:
					top1 = THIS_TILE_PERIMETER.Bottom; 
					top2 = THIS_TILE_PERIMETER.Right;
					break;
					
				// Грань, параллельная YOZ. Такие грани возникают между тайлами
				// в соседних столбцах, расположенных в ячейках по оси OX
				// (ось направлена от цента влево-вниз).
				case VerticalFaceType.YOZ_PARALLEL:
					top1 = THIS_TILE_PERIMETER.Left; 
					top2 = THIS_TILE_PERIMETER.Bottom;
					break;
			} // switch ( parVerticalFaceType )	
			
			// Первая нижняя точки грани.
			var bottom1: Point;
			// Вторая нижняя точки грани.
			var bottom2: Point;
			
			// Если тайл находится с краю, то соседнего тайла для образования
			// грани-соединения нет, поэтому нижнее ребро грани будет
			// принадлежать плосоксти XOY.
			if ( nextTileCellLocation == null )
			{
				bottom1 = new Point( top2.x, top2.y + THIS_TILE_Z_HEIGHT ); 
				bottom2 = new Point( top1.x, top1.y + THIS_TILE_Z_HEIGHT ); 
			} // if ( nextTileCellLocation == null )
			else
			{
				// Периметр следующего тайла.
				const NEXT_TILE_PERIMETER: IsometricParallelToXOYSquare
					= this._LandscapeModel.IsometricLocations
					[ nextTileCellLocation.YRow ][ nextTileCellLocation.XColumn ];
				
				switch ( parVerticalFaceType )
				{
					// Грань, параллельная XOZ. Такие грани возникают между тайлами
					// в соседних строках, расположенных в ячейках по оси OY
					// (ось направлена от цента вправо-вниз).
					case VerticalFaceType.XOZ_PARALLEL:
						bottom1 = NEXT_TILE_PERIMETER.TopAndLocalOrigin; 
						bottom2 = NEXT_TILE_PERIMETER.Left; 
						break;
						
					// Грань, параллельная YOZ. Такие грани возникают между тайлами
					// в соседних столбцах, расположенных в ячейках по оси OX
					// (ось направлена от цента влево-вниз).
					case VerticalFaceType.YOZ_PARALLEL:
						bottom1 = NEXT_TILE_PERIMETER.Right; 
						bottom2 = NEXT_TILE_PERIMETER.TopAndLocalOrigin; 
						break;
				} // switch ( parVerticalFaceType )
			} // else: if ( nextTileCellLocation != null )
			
			// Отрисовка в растровых данных изображения грани.
			VerticalFacesView.DrawFaceBitmap( thisVerticalFace, 
				top1, top2, bottom1, bottom2, TOP_COLOR, BOTTOM_COLOR );
		} // SetVerticalFaceAfterTile
		
		/**
		 * Метод отрисовки в растровых данных изображения грани.
		 * У вертикальной грани есть две верхние точки и две нижние точки.
		 * @param parFaceBitmap Ссылка на изображение грани.
		 * @param parTop1 Первая верхняя точка грани.
		 * @param parTop2 Вторая верхняя точка грани.
		 * @param parBottom1 Первая нижняя точка грани.
		 * @param parBottom2 Вторая нижняя точка грани.
		 * @param parTopColor Цвет верха параллелограмма ветрикальной грани.
		 * @param parBottomColor Цвет низа параллелограмма ветрикальной грани.
		 */
		private static function DrawFaceBitmap
		(
			parFaceBitmap: Bitmap,
			parTop1: Point,
			parTop2: Point,
			parBottom1: Point,
			parBottom2: Point,
			parTopColor: uint,
			parBottomColor: uint
		): void
		{
			// ВАЖНО!!! Здесь используется метод Point.clone(),
			// иначе далее будут точки корректироваться,
			// поскольку они - объекты ссылочного типа.			
			
			// Первая верхняя точки грани.
			var top1: Point = parTop1.clone( );
			// Вторая верхняя точки грани.
			var top2: Point = parTop2.clone( );
			// Первая нижняя точки грани.
			var bottom1: Point = parBottom1.clone( );
			// Вторая нижняя точки грани.
			var bottom2: Point = parBottom2.clone( );
			
			// Положение локальной точки начала координат отрисовки изображения.
			// Эта же точка - новая координата отображаемого объекта грани
			// относительно объекта-контейнера.
			const ORIGIN: Point = new Point( top1.x, Math.min( top1.y, top2.y ) );
			// Точка с максимальными координатами прямоугольника, ограничикающего
			// изображение грани.
			const MAXIMUM_POINT: Point = new Point( top2.x,
				Math.max( bottom1.y, bottom2.y ) );
				
			// Смещение полученных точек периметра грани в локальное начало координат.
			// ВНИМАНИЕ!!! Как раз для этого момента были нужны методы Point.clone( ).
			top1.x -= ORIGIN.x;
			top2.x -= ORIGIN.x;
			bottom1.x -= ORIGIN.x;
			bottom2.x -= ORIGIN.x;
			top1.y -= ORIGIN.y;
			top2.y -= ORIGIN.y;
			bottom1.y -= ORIGIN.y;
			bottom2.y -= ORIGIN.y;
			
			// Ширина получаемого изображения.
			const WIDTH: Number = Math.abs( MAXIMUM_POINT.x - ORIGIN.x );
			// Высота получаемого изображения.
			const HEIGHT: Number = Math.abs( MAXIMUM_POINT.y - ORIGIN.y );
			
			// Создание и отрисовка соответствующей формы.
			var shape: Shape = new Shape( );
			shape.graphics.lineStyle( VerticalFacesView.LINE_THICKNESS,
				VerticalFacesView.LINE_COLOR, 1, false, LineScaleMode.VERTICAL,
				CapsStyle.NONE, JointStyle.MITER,
				VerticalFacesView.LINE_MITER_LIMIT );
			var matrix: Matrix = new Matrix( );
			matrix.createGradientBox( WIDTH, HEIGHT, 1.5 * Math.PI, 0, 0 );
			shape.graphics.beginGradientFill( GradientType.LINEAR,
				[ parBottomColor, parTopColor ], [ 1, 1 ], [ 0x00, 0xFF ], matrix,
				SpreadMethod.PAD );
			shape.graphics.moveTo( top1.x, top1.y );			
			shape.graphics.lineTo( top2.x, top2.y );
			shape.graphics.lineTo( bottom1.x, bottom1.y );
			shape.graphics.lineTo( bottom2.x, bottom2.y );
			shape.graphics.lineTo( top1.x, top1.y );
			shape.graphics.endFill( );
			shape.cacheAsBitmap = true;
			shape.x = 0;
			shape.y = 0;
			
			// У картинки есть свой фон.
			// public function BitmapData(width:int, height:int,
			// transparent:Boolean = true, fillColor:uint = 0xFFFFFFFF)
			// То есть по умолчанию фон белый: fillColor = 0xFFFFFFFF,
			// Чтобы создать полностью прозрачное растровое изображение,
			// параметру transparent нужно присвоить значение true,
			// а параметру fillColor — 0x00000000 (или 0).
			var bitmapData: BitmapData = new BitmapData
				( WIDTH + 2 * VerticalFacesView.LINE_THICKNESS,
				HEIGHT + 2 * VerticalFacesView.LINE_THICKNESS, true, 0 );
			bitmapData.draw( shape );
			parFaceBitmap.bitmapData = bitmapData;
			parFaceBitmap.x = ORIGIN.x + VerticalFacesView.SHAPE_OFFSET.x;
			parFaceBitmap.y = ORIGIN.y + VerticalFacesView.SHAPE_OFFSET.y;
			// Отображение граней на сцене я решаю через прозрачность,
			// чтобы потомков не удалять и их последовательность не перепуталась бы.
			parFaceBitmap.alpha = 1;			
		} // DrawFaceBitmap
		
		/**
		 * Ассоциативный массив, ключи которого - типы граней,
		 * значения - матрицы отображаемых объектов граней.
		 * @return Ассоциативный массив, ключи которого - типы граней,
		 * значения - матрицы отображаемых объектов граней.
		 */		
		public function get Faces( ): Object
    { 
    	return this._Faces;
		}	// get Faces
	} // VerticalFacesView	
} // hillyLandscape.view
