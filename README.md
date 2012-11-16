CadetEngine
===========

CadetEngine is a component based AS3 Scene Engine which supports 2D and 3D rendering and physics, custom behaviours and 3rd party library integration.

The CadetEngine framework is broken down into layers, each layer adds additional features via it's own Flex Library project.

Cadet (core)
------------

Dependencies: [FloxApp](https://github.com/unwrong/FloxApp)

[Cadet](https://github.com/unwrong/CadetEngine/tree/master/cadet) is the core scene engine, containing the classes [Component](https://github.com/unwrong/CadetEngine/blob/master/cadet/src/cadet/core/Component.as), [ComponentContainer](https://github.com/unwrong/CadetEngine/blob/master/cadet/src/cadet/core/ComponentContainer.as) and [CadetScene](https://github.com/unwrong/CadetEngine/blob/master/cadet/src/cadet/core/CadetScene.as). All children of the CadetScene must be Components and all Components which have children must be ComponentContainers, for instance, CadetScene extends ComponentContainer, which in turn extends Component.

The Cadet core library can be used in conjunction with vanilla Starling, Away3D, etc projects in order to add game processes and behaviours. If however you wish to integrate Cadet projects with the [CadetEditor](http://www.cadeteditor.com), the Cadet2D and Cadet3D libraries must be used; as well as providing a game (or scene) engine, Cadet serves to provide a single layer of abstraction around 3rd party libraries, making them palatable to the editor. If a property is marked with the [[Inspectable]](https://github.com/unwrong/CadetEngine/blob/master/cadet/src/cadet/core/Component.as#L134) metadata it is automatically made available to CadetEditor's property inspector.

[Examples](https://github.com/unwrong/CadetEngine/examples/cadet)

Cadet2D
-------

Dependencies: [Cadet (core)](https://github.com/unwrong/CadetEngine/tree/master/cadet), [FloxApp](https://github.com/unwrong/FloxApp), [Starling](https://github.com/PrimaryFeather/Starling-Framework)

Cadet2D augments Cadet with 2D Rendering capability (via Starling) and various 2D-specific geometries, skins, behaviours and processes.

[Examples](https://github.com/unwrong/CadetEngine/examples/cadet2D)

Cadet2DBox2D
------------

Dependencies: [Cadet (core)](https://github.com/unwrong/CadetEngine/tree/master/cadet), [Cadet2D](https://github.com/unwrong/CadetEngine/tree/master/cadet2D)

Cadet2DBox2D augments Cadet2D with a suite of physics behaviours and processes powered by the [Box2D](http://box2dflash.sourceforge.net/) library. Cadet2DBox2D has been separated from Cadet2D in order to allow Cadet2D to be augmented by other physics engines (e.g. [Nape](https://github.com/deltaluca/nape)) without bundling all of the various implementations into one bloated library. It could also be the case that the user may wish to simply use Cadet2D without requiring physics. 

[Examples](https://github.com/unwrong/CadetEngine/examples/cadet2DBox2D)
 
Cadet3D
-------

Dependencies: [Cadet (core)](https://github.com/unwrong/CadetEngine/tree/master/cadet), [FloxApp](https://github.com/unwrong/FloxApp), [Away3D](https://github.com/away3d/away3d-core-fp11)

Cadet3D augments Cadet with 3D Rendering capability (via Away3D) and various 3D-specific geometries, materials, lights, cameras, textures, etc. 

[Examples](https://github.com/unwrong/CadetEngine/examples/cadet3D)

Cadet3DPhysics
--------------

Dependencies: [Cadet (core)](https://github.com/unwrong/CadetEngine/tree/master/cadet), [Cadet3D](https://github.com/unwrong/CadetEngine/tree/master/cadet3D), [AwayPhysics](https://github.com/away3d/awayphysics-core-fp11)

Cadet3DPhysics augments Cadet3D with physics behaviours and processes powered by the [AwayPhysics](https://github.com/away3d/awayphysics-core-fp11) library. Cadet3DPhysics has been separated from Cadet3D because users may wish to simply use Cadet3D and not require physics.

[Examples](https://github.com/unwrong/CadetEngine/examples/cadet3DPhysics)