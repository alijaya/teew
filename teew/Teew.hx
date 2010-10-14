package teew;


class Teew 
{
	static public var teews:Array<Teew> = [];

	static inline public function tween(target:Dynamic, duration:Int) : Teew
	{
		return new Teew(target, duration).start();
	}

	static inline public function add(t:Teew) : Teew
	{
		if(!Lambda.has(Teew.teews, t)) Teew.teews.push(t);

		t.init();

		return t;
	}

	static inline public function remove(t:Teew) : Teew
	{
		if(Lambda.has(Teew.teews, t)) Teew.teews.remove(t);

		return t;
	}

	static inline public function stepAll()
	{
		for(n in teews)
		{
			n.step();
		}
	}

	static inline public function initTimer(delay:Int)
	{
		var timer = new haxe.Timer(delay);
		timer.run = stepAll;
	}

	public var target(default, null) : Dynamic;
	public var time(default, null) : Int;
	public var duration(default, null) : Int;
	public var easingFunc(default, null) : Float->Float;
	
	
	public var nextTeew(default, null) : Teew;
	public var nextF(default, null) : Void->Void;
	
	
	public var props(default, null) : Hash<Range>;
	public var iprops(default, null) : Hash<IRange>;
	public var funcs(default, null) : Array<TFunc>;
	public var ifuncs(default, null) : Array<TIFunc>;
	
	public function new(target:Dynamic, duration:Int)
	{
		this.target = target;
		this.duration = duration;
		this.time = 0;
		this.easingFunc = Easing.linear;
		props = new Hash<Range>();
		iprops = new Hash<IRange>();
		funcs = [];
		ifuncs = [];
	}

	public function init() : Void
	{
		for(n in props.keys())
		{
			var t = props.get(n);
			if(t.to == null)
			{
				var by = t.from;
				t.from = Reflect.field(target, n);
				t.to = t.from + by;
			} else if(t.from == null) t.from = Reflect.field(target, n);
		}
		for(n in iprops.keys())
		{
			var t = props.get(n);
			if(t.to == null)
			{
				var by = t.from;
				t.from = Reflect.field(target, n);
				t.to = t.from + by;
			} else if(t.from == null) t.from = Reflect.field(target, n);
		}
	}
	

	public function easing(easingFunc:Float->Float) : Teew
	{
		this.easingFunc = easingFunc;

		return this;
	}
	

	public function to(prop:String, to:Float) : Teew
	{
		props.set(prop, {from:null, to:to});

		return this;
	}

	public function ito(iprop:String, ito:Int) : Teew
	{
		iprops.set(iprop, {from:null, to:ito});

		return this;
	}

	public function by(prop:String, by:Float) : Teew
	{
		props.set(prop, {from:by, to:null});

		return this;
	}

	public function iby(iprop:String, iby:Int) : Teew
	{
		iprops.set(iprop, {from:iby, to:null});

		return this;
	}
	

	public function fromTo(prop:String, from:Float, to:Float) : Teew
	{
		props.set(prop, {from:from, to:to});
		update(prop);

		return this;
	}
	
	public function ifromTo(iprop:String, ifrom:Int, ito:Int) : Teew
	{
		iprops.set(iprop, {from:ifrom, to:ito});
		update(iprop);

		return this;
	}

	public function func(f:Dynamic->Float->Void, from:Float, to:Float) : Teew
	{
		funcs.push({func:f, range:{from:from, to:to}});

		return this;
	}
	
	public function ifunc(f:Dynamic->Int->Void, ifrom:Int, ito:Int) : Teew
	{
		ifuncs.push({func:f, range:{from:ifrom, to:ito}});

		return this;
	}

	public function nextFunc(func:Void->Void) : Teew
	{
		nextF = func;

		return this;
	}
	
	

	public function next(duration:Int) : Teew
	{
		nextTeew = new Teew(target, duration);

		return nextTeew;
	}

	public function step() : Void
	{
		time++;
		
		for(n in props.keys())
		{
			update(n);
		}
		for(n in iprops.keys())
		{
			iupdate(n);
		}
		for(n in funcs)
		{
			n.func(target, easingFunc(time/duration) * (n.range.to-n.range.from) + n.range.from);
		}
		for(n in ifuncs)
		{
			n.func(target, Std.int(easingFunc(time/duration) * (n.range.to-n.range.from) + n.range.from));
		}
		
		if(time >= duration)
		{
			stop();
			return;
		}
		
	}

	public function update(prop:String) : Void
	{
		var range = props.get(prop);
		if(Reflect.isFunction(Reflect.field(target, prop)))
		{
			Reflect.callMethod(target, prop, [easingFunc(time/duration) * (range.to-range.from) + range.from]);
		} else
		{
			Reflect.setField(target, prop, easingFunc(time/duration) * (range.to-range.from) + range.from);
		}
	}

	public function iupdate(iprop:String) : Void
	{
		var range = iprops.get(iprop);
		if(Reflect.isFunction(Reflect.field(target, iprop)))
		{
			Reflect.callMethod(target, iprop, [Std.int(easingFunc(time/duration) * (range.to-range.from) + range.from)]);
		} else
		{
			Reflect.setField(target, iprop, Std.int(easingFunc(time/duration) * (range.to-range.from) + range.from));
		}
	}
	
	
	public function start() : Teew
	{
		time = 0;
		
		Teew.add(this);
		
		return this;
	}
	
	public function stop() : Teew
	{
		time = 0;

		Teew.remove(this);
		if(nextF!=null) nextF();
		if(nextTeew!=null) nextTeew.start();

		return this;
	}	
}

typedef Range = {from:Null<Float>, to:Null<Float>}
typedef IRange = {from:Null<Int>, to:Null<Int>}
typedef TFunc = {func:Dynamic->Float->Void, range:Range}
typedef TIFunc = {func:Dynamic->Int->Void, range:IRange}
