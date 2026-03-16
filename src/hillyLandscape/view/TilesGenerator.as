/**
 * Пакет визуальных представлений игровых объектов.
 */
package hillyLandscape.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;	
	import flash.display.Shape;
	import geom.Utils;
	import geom.IsometricXOYGrid;
	import geom.IsometricParallelToXOYRectangle;
	import geom.IsometricParallelToXOYSquare;
	import flash.geom.Point;
	
	/**
	 * Генератор тайлов. 
	 */
	public class TilesGenerator
	{
		/**
		 * Цвет заливки тайла неопределённого типа.
		 */
		public static const UNDEFINED_TILE_FILL_COLOR: uint = 0x00FFDE65;
		/**
		 * Толщина линии тайла неопределённого типа.
		 */
		public static const UNDEFINED_TILE_LINE_THICKNESS: Number = 3;
		/**
		 * Цвет линии тайла неопределённого типа.
		 */
		public static const UNDEFINED_TILE_LINE_COLOR: uint = 0x00000000;
		/**
		 * Предел обрезки скоса угла линии тайла неопределённого типа.
		 */
		public static const UNDEFINED_TILE_LINE_MITER_LIMIT: Number = 5;
		
		/**
		 * Изображение тайла неопределённого типа.
		 */
		private var _UndefinesTileBitmapData: BitmapData = null;
		/**
		 * Сторона клетки изметрической сетки в пикселях.
		 */
		private var _CellSide: Number = IsometricXOYGrid.MINIMUM_CELL_SIDE;		
				 
		/**
		 * Инициализация генератора тайлов.
		 * @param parCellSide Сторона клетки изметрической сетки в пикселях.
		 */
		public function TilesGenerator( parCellSide: Number
			= IsometricXOYGrid.MINIMUM_CELL_SIDE ): void
		{
			this._CellSide = Math.max( parCellSide,
				IsometricXOYGrid.MINIMUM_CELL_SIDE );
			// Инициализация тайла неопределённого типа.
			this.InitialiazeUndefinesTileBitmapData
				( new IsometricParallelToXOYSquare( new Point( ), this._CellSide ) );
		} // TilesGenerator					 
		
		/**
		 * Инициализация тайла неопределённого типа.
		 * @param parPerimeter Изометрический прямоугольник периметра тайла.
		 */
		private function InitialiazeUndefinesTileBitmapData
			( parPerimeter: IsometricParallelToXOYRectangle ): void
		{
			// Дополнительное смещение.
			/*var additionalOffset: Number = 1;*//*TilesGenerator
				.UNDEFINED_TILE_LINE_THICKNESS / 2;*/
			// Отрицательные координаты при рисовании в объект BitmapData
			// пропадают, поэтому переметр следует переместить так,
			// чтобы все его точки были положительными.
			/*parPerimeter.Move( new Point ( parPerimeter.XSide * Utils.SIN_60
				+ additionalOffset, additionalOffset ) );*/
			parPerimeter.Move( new Point( parPerimeter.XSide * Utils.SIN_60
				+ TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS,
				TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS ) );
			
			// Форма для отрисовки тайла неопределённого типа.
			var shape: Shape = new Shape( );
			shape.graphics.lineStyle( TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS,
				TilesGenerator.UNDEFINED_TILE_LINE_COLOR, 1, false, LineScaleMode.VERTICAL,
				CapsStyle.NONE, JointStyle.MITER,
				TilesGenerator.UNDEFINED_TILE_LINE_MITER_LIMIT );
			shape.graphics.beginFill( TilesGenerator.UNDEFINED_TILE_FILL_COLOR );
			shape.graphics.moveTo( parPerimeter.TopAndLocalOrigin.x,
				parPerimeter.TopAndLocalOrigin.y );			
			shape.graphics.lineTo( parPerimeter.Right.x, parPerimeter.Right.y );
			shape.graphics.lineTo( parPerimeter.Bottom.x, parPerimeter.Bottom.y );
			shape.graphics.lineTo( parPerimeter.Left.x, parPerimeter.Left.y );
			shape.graphics.lineTo( parPerimeter.TopAndLocalOrigin.x,
				parPerimeter.TopAndLocalOrigin.y );
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
			this._UndefinesTileBitmapData = new BitmapData
				( shape.width + TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS,
				shape.height + TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS,
				true, 0x00000000 );			
			this._UndefinesTileBitmapData.draw( shape );
		} // InitialiazeUndefinesTileBitmapData		
		
		/**
		 * Получение отображаемого объекта тайла.
		 * @param parTileImage Информация об изображении плитки.
		 * @param parTilePerimeter Изометрический прямоугольник размещения тайла.		 
		 * @return Сгенерированное изображение плитки.
		 */
		public function GenerateBitmap( parTileImage: TileImage,
			parTilePerimeter: IsometricParallelToXOYRectangle ): Bitmap
		{
			if ( parTilePerimeter == null )
				parTilePerimeter = new IsometricParallelToXOYSquare
					( new Point( ), this._CellSide );
				
			// Растровые данные тайла.
			var bitmapData: BitmapData;
			// Смещение, на которое должен смещаться центр изображения
			// относительно центра его ячейки изометрической сетки.
			var offset: Point;
			// Если изображение не определено, то оно заменяется специальными
			// сохранёнными в этом классе данными.
			if ( ( parTileImage == null ) || ( parTileImage.Image == null ) )
			{
				bitmapData = this._UndefinesTileBitmapData;
				offset = new Point( TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS,
					TilesGenerator.UNDEFINED_TILE_LINE_THICKNESS );
			} // if
			else
			{
				bitmapData = parTileImage.Image;
				offset = parTileImage.Offset;
			} // else
			
			// Отображаемый объект, содержащий полученное изображение.
			var bitmap: Bitmap = new Bitmap( bitmapData );
			bitmap.cacheAsBitmap = true;
			
			// Отцентровка полученного отображаемого объекта
			// в пределах границ заданного периметра.
			parTilePerimeter.PutDisplayObjectToCenter( bitmap );
			bitmap.x += offset.x;
			bitmap.y += offset.y;
			
			return bitmap;
		} // GenerateBitmap
	} // TilesGenerator	
} // hillyLandscape.model
