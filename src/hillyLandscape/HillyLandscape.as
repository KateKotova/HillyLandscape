/**
 * Пакет ландшафта переменной высоты.
 */
package hillyLandscape
{
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import hillyLandscape.controller.HillyLandscapeController;
	
	/**
	 * Класс ландшафта переменной высоты.
	 */	
	public class HillyLandscape extends Sprite
	{
		/**
		 * Контроллер ландшафта переменной высоты.
		 */
		private var _Controller: HillyLandscapeController;		
		
		/**
		 * Конструктор ландшафта переменной высоты.
		 */		
		public function HillyLandscape( )
		{
			// Инициализация сцены.
			this.InitializeStage( );
			this._Controller = new HillyLandscapeController( this );		
		} // HillyLandscape
		
		/*
		 * Метод инициализации сцены.
		 */
		private function InitializeStage( ): void	{
			// Класс Stage представляет основную область рисования.
			// К объекту Stage нет глобального доступа.
			// Доступ к нему осуществляется через свойство stage
			// экземпляра DisplayObject.

			// Выравнивание рабочей области
			// в проигрывателе Flash Player или обозревателе:
			// выравнивание по вертикали - верхний край,
			// выравнивание по горизонтали - левый край.
			this.stage.align = StageAlign.TOP_LEFT;
			// Состояние отображения:
			// рабочая область разворачивается на весь экран пользователя,
			// а ввод с клавиатуры отключается.
			/* this.stage.displayState = StageDisplayState.FULL_SCREEN; */
			// Качество визуализации:
			// очень высокое качество визуализации, графика сглаживается
			// по сетке 4 x 4 пиксела, растровые изображения всегда смягчаются.
			this.stage.quality = StageQuality.BEST;
			// Режим масштабирования:
			// фиксируется размер всего приложения, так что он сохраняется даже
			// при изменении размеров окна проигрывателя, если окно проигрывателя
			// меньше размеров содержимого, может возникнуть усечение.
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			// Отображение или скрытие элементов по умолчанию
			// в контекстном меню Flash Player:
			// true - появляются все элементы контекстного меню,
			// false - отображаются только элементы меню "Параметры"
			// и "О проигрывателе Adobe Flash Player".
			this.stage.showDefaultContextMenu = false;
			// Признак отображения светящейся рамки вокруг объектов в фокусе. 
			this.stage.stageFocusRect = false;
			// Признак включения перехода между потомками объекта с помощью Tab.
			this.stage.tabChildren = true;
		} // InitializeStage		
	}	// HillyLandscape
} // hillyLandscape
