CadetEngine
===========

CadetEngine is a component-based AS3 Scene Engine which supports 2D and 3D GPU accelerated rendering, physics, custom behaviours and 3rd party library integration.

The CadetEngine framework supports extensibility by being separated into tiers, each tier augments the Cadet core library via it's own Flex Library project.

Cadet (core)
------------

Dependencies: [CoreApp](https://github.com/CadetEditor/CoreApp-as)

[Cadet](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet) is the core scene engine, a bare bones structure containing (amongst others) the classes [Component](https://github.com/CadetEditor/CadetEngine-as/blob/master/cadet/src/cadet/core/Component.as), [ComponentContainer](https://github.com/CadetEditor/CadetEngine-as/blob/master/cadet/src/cadet/core/ComponentContainer.as) and [CadetScene](https://github.com/CadetEditor/CadetEngine-as/blob/master/cadet/src/cadet/core/CadetScene.as). All children of the CadetScene must be Components and all Components which have children must be ComponentContainers, for instance, CadetScene extends ComponentContainer, which in turn extends Component.

The Cadet core library can be used in conjunction with vanilla Starling, Away3D, etc projects in order to add game processes and behaviours. However, if you wish to integrate Cadet projects with the [CadetEditor](http://www.cadeteditor.com), the Cadet2D and Cadet3D libraries must be used. Cadet2D and Cadet3D wrap up Starling and Away3D implementations respectively via a single layer of abstraction, providing a simple wrapper API which allows specific properties to be inspectable via the property inspector and serializable using the serialization lib. Cadet2D and Cadet3D give Starling and Away3D a presence in the Cadet scene graph in the same way Cadet2DBox2D gives Box2D a presence in the scene graph. The CadetEditor solely acts upon the Cadet scene graph, so anything that needs to be editable needs to have a presence within it. 

It's worth noting that Cadet doesn't get mixed up in the internal execution of any 3rd party libraries, it simply provides hooks for adding and removing entities to/from those libraries, and adding/removing instances of the libraries themselves; it does all of this by simply calling the 3rd party library's public API.

[Examples](https://github.com/CadetEditor/CadetEngine-as/tree/master/examples/cadet)

Cadet2D
-------

Dependencies: [Cadet (core)](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet), [CoreApp](https://github.com/CadetEditor/CoreApp-as), [Starling](https://github.com/PrimaryFeather/Starling-Framework), [Starling-Extension-Graphics](https://github.com/unwrong/Starling-Extension-Graphics), [Starling-Extension-Particle-System](https://github.com/PrimaryFeather/Starling-Extension-Particle-System)

Cadet2D augments Cadet with 2D Rendering capability (via Starling and Starling-Extension-Graphics) and adds various 2D-specific geometries, skins, behaviours and processes. It also supports particles via Starling-Extension-Particle-System.

[Examples](https://github.com/CadetEditor/CadetEngine-as/tree/master/examples/cadet2D)

Cadet2DBox2D
------------

Dependencies: [Cadet (core)](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet), [Cadet2D](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet2D)

Cadet2DBox2D augments Cadet2D with a suite of physics behaviours and processes powered by the [Box2D](http://box2dflash.sourceforge.net/) library. Cadet2DBox2D has been separated from Cadet2D in order to allow Cadet2D to be augmented by other physics engines without bundling all of the various implementations into one bloated library. It may also be the case that the user wishes to simply use Cadet2D without requiring physics. 

[Examples](https://github.com/CadetEditor/CadetEngine-as/tree/master/examples/cadet2DBox2D)
 
Cadet3D
-------

Dependencies: [Cadet (core)](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet), [CoreApp](https://github.com/CadetEditor/CoreApp-as), [Away3D](https://github.com/away3d/away3d-core-fp11)

Cadet3D augments Cadet with 3D Rendering capability (via Away3D) and various 3D-specific geometries, materials, lights, cameras, textures, etc. 

[Examples](https://github.com/CadetEditor/CadetEngine-as/tree/master/examples/cadet3D)

Cadet3DPhysics
--------------

Dependencies: [Cadet (core)](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet), [Cadet3D](https://github.com/CadetEditor/CadetEngine-as/tree/master/cadet3D), [AwayPhysics](https://github.com/away3d/awayphysics-core-fp11)

Cadet3DPhysics augments Cadet3D with physics behaviours and processes powered by the [AwayPhysics](https://github.com/away3d/awayphysics-core-fp11) library. Cadet3DPhysics has been separated from Cadet3D as users may wish to simply use Cadet3D and not require physics, or perhaps try a different physics engine.

[Examples](https://github.com/CadetEditor/CadetEngine-as/tree/master/examples/cadet3DPhysics)