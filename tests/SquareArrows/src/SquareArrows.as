package
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	/**
	 * Sample class to draw squares and arrows between them.
	 */
	public class SquareArrows extends Sprite
	{
		/**
		 * Initialize the scene as soon as we can.
		 */
		public function SquareArrows()
		{
			if(stage) {
				init();
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 * Draw two squares and an arrow between them.
		 */
		private function init(e : Event = null) : void
		{
			if(hasEventListener(Event.ADDED_TO_STAGE)) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}
			
			// Drawing random-sized squares.
			var squareOne : Shape =
				getSquareShape((Math.random() * 50) + 20, 0xBBBBBB);
			var squareTwo : Shape =
				getSquareShape((Math.random() * 50) + 20, 0xDDDDDD);
			addChild(squareOne);
			addChild(squareTwo);
			
			// Draw the connector.
			var connector : Shape = getConnectorShape(squareOne, squareTwo);
			addChild(connector);
		}
		
		/**
		 * Draw a connector arrow between two square shapes.
		 */
		private function getConnectorShape(connectFrom : Shape, connectTo : Shape) : Shape
		{
			// Getting the center of the first square.
			var centerFrom : Point = new Point();
			centerFrom.x = connectFrom.x + (connectFrom.width / 2);
			centerFrom.y = connectFrom.y + (connectFrom.height / 2);
			
			// Getting the center of the second square.
			var centerTo : Point = new Point();
			centerTo.x = connectTo.x + (connectTo.width / 2);
			centerTo.y = connectTo.y + (connectTo.height / 2);
			
			// Getting the angle between those two.
			var angleTo : Number =
				Math.atan2(centerTo.x - centerFrom.x, centerTo.y - centerFrom.y);
			var angleFrom : Number =
				Math.atan2(centerFrom.x - centerTo.x, centerFrom.y - centerTo.y);
			
			// Getting the points on both borders.
			var pointFrom : Point = getSquareBorderPointAtAngle(connectFrom, angleTo);
			var pointTo : Point = getSquareBorderPointAtAngle(connectTo, angleFrom);
			
			// Calculating arrow edges.
			var arrowSlope : Number = 30;
			var arrowHeadLength : Number = 10;
			var vector : Point =
				new Point(-(pointTo.x - pointFrom.x), -(pointTo.y - pointFrom.y));
			
			// First edge of the head...
			var edgeOneMatrix : Matrix = new Matrix();
			edgeOneMatrix.rotate(arrowSlope * Math.PI / 180);
			var edgeOneVector : Point = edgeOneMatrix.transformPoint(vector);
			edgeOneVector.normalize(arrowHeadLength);
			var edgeOne : Point = new Point();
			edgeOne.x = pointTo.x + edgeOneVector.x;
			edgeOne.y = pointTo.y + edgeOneVector.y;
			
			// And second edge of the head.
			var edgeTwoMatrix : Matrix = new Matrix();
			edgeTwoMatrix.rotate((0 - arrowSlope) * Math.PI / 180);
			var edgeTwoVector : Point = edgeTwoMatrix.transformPoint(vector);
			edgeTwoVector.normalize(arrowHeadLength);
			var edgeTwo : Point = new Point();
			edgeTwo.x = pointTo.x + edgeTwoVector.x;
			edgeTwo.y = pointTo.y + edgeTwoVector.y;
			
			// Drawing the arrow.
			var arrow : Shape = new Shape();
			with(arrow.graphics) {
				lineStyle(2);
				// Drawing the line.
				moveTo(pointFrom.x, pointFrom.y);
				lineTo(pointTo.x, pointTo.y);
				
				// Drawing the arrow head.
				lineTo(edgeOne.x, edgeOne.y);
				moveTo(pointTo.x, pointTo.y);
				lineTo(edgeTwo.x, edgeTwo.y);
			}
			return arrow;
		}
		
		/**
		 * Utility method to get a point on a square border at a certain angle.
		 */
		private function getSquareBorderPointAtAngle(square : Shape, angle : Number) : Point
		{
			// Calculating rays of inner and outer circles.
			var minRay : Number = Math.SQRT2 * square.width / 2;
			var maxRay : Number = square.width / 2;
			
			// Calculating the weight of each rays depending on the angle.
			var rayAtAngle : Number = ((maxRay - minRay) * Math.abs(Math.cos(angle * 2))) + minRay;
			
			// We have our point.
			var point : Point = new Point();
			point.x = rayAtAngle * Math.sin(angle) + square.x + (square.width / 2);
			point.y = rayAtAngle * Math.cos(angle) + square.y + (square.height / 2);
			return point;
		}
		
		/**
		 * Utility method to draw a square of a given size in a new shape.
		 */
		private function getSquareShape(edgeSize : Number, fillColor : Number) : Shape
		{
			// Draw the square.
			var square : Shape = new Shape();
			with(square.graphics) {
				lineStyle(1);
				beginFill(fillColor);
				drawRect(0, 0, edgeSize, edgeSize);
				endFill();
			}
			
			// Set a random position.
			square.x = Math.random() * (stage.stageWidth - square.width);
			square.y = Math.random() * (stage.stageHeight - square.height);
			
			return square;
		}
	}
}
