package ;

import flash.display.Sprite;
import flash.Lib;

import flash.filters.BlurFilter;

import teew.Teew;
import teew.Easing;

class Main 
{


	static function main() : Void
	{
		new Main();
	}

	var blurFilter : BlurFilter;
	
	public function new()
	{
		blurFilter = new BlurFilter(0, 0);
		
		var s = new Sprite();
		s.graphics.beginFill(0xFF0000);
		s.graphics.drawCircle(0, 0, 20);

		Lib.current.addChild(s);

		Teew.initTimer(10);
		Teew.tween(s, 200).fromTo("x", 20, 780).fromTo("y", 20, 20).ifunc(interpolate, 0, 255).easing(Easing.circ)
		.next(200).to("y", 580).ifunc(interpolate, 255, 0).easing(Easing.expo)
		.next(200).to("x", 20).ifunc(interpolate, 0, 255).easing(Easing.back)
		.next(200).to("y", 20).ifunc(interpolate, 255, 0).easing(Easing.reverse(Easing.bounce))
		.next(400).to("x", 400).to("y", 300).to("scaleX", 3).to("scaleY", 3).func(blur, 0, 100).easing(Easing.reflect(Easing.elastic))
		.nextFunc(function()trace("Finish :D"));
	}

	public function interpolate(sprite:Sprite, value:Int) : Void
	{
		sprite.graphics.clear();
		sprite.graphics.beginFill(255<<16|value<<8);
		sprite.graphics.drawCircle(0, 0, 20);
	}

	public function blur(sprite:Sprite, value:Float) : Void
	{
		blurFilter.blurX = value;
		blurFilter.blurY = value;
		sprite.filters = [blurFilter];
	}
	
	
}
