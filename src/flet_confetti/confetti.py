import math
import json
from dataclasses import field
from enum import Enum
from typing import Any, List, Optional

import flet as ft
from flet.controls.types import ColorValue

class ConfettiBlastDirectionality(str, Enum):
    EXPLOSIVE = "explosive"
    DIRECTIONAL = "directional"

class ConfettiShape(str, Enum):
    CIRCLE = "circle"
    SQUARE = "square"
    STAR = "star"
    HEART = "heart"
    TRIANGLE = "triangle"
    DIAMOND = "diamond"

@ft.control("Confetti")
class Confetti(ft.Control):
    """
    Confetti widget bridging to Flutter's confetti package.
    """

    blast_directionality: ConfettiBlastDirectionality = ConfettiBlastDirectionality.DIRECTIONAL
    """
    State if the particles shoot in random directions or a specific direction.
    """

    shape: ConfettiShape = ConfettiShape.CIRCLE
    """
    Shape of the confetti particles.
    """

    blast_direction: float = math.pi
    """
    Radial value to determine the direction of the particle emission. Default is PI (left).
    """

    emission_frequency: float = 0.02
    """
    Value between 0 and 1. Higher value = higher likelihood of particles per frame.
    """

    number_of_particles: int = 10
    """
    Number of particles emitted per emission.
    """

    should_loop: bool = False
    """
    Determines if the emission will reset after duration is completed.
    """

    max_blast_force: float = 20.0
    """
    Maximum blast force applied to a particle.
    """

    min_blast_force: float = 5.0
    """
    Minimum blast force applied to a particle.
    """

    display_target: bool = False
    """
    If true a crosshair will be displayed to show the location of the particle emitter.
    """

    colors: Optional[List[ColorValue]] = None
    """
    List of colors for the confetti.
    """

    colors_json: Optional[str] = field(default=None, init=False)

    stroke_width: float = 0.0
    """
    Stroke width of the confetti.
    """

    stroke_color: Optional[ColorValue] = None
    """
    Stroke color of the confetti.
    """

    gravity: float = 0.1
    """
    Speed at which the confetti falls (0 to 1).
    """

    particle_drag: float = 0.05
    """
    Drag force to apply to the confetti (0 to 1).
    """

    min_particle_width: float = 20.0
    """
    Minimum width of the confetti particle.
    """

    min_particle_height: float = 10.0
    """
    Minimum height of the confetti particle.
    """

    max_particle_width: float = 20.0
    """
    Maximum width of the confetti particle.
    """

    max_particle_height: float = 10.0
    """
    Maximum height of the confetti particle.
    """

    custom_shape: Optional[List[Any]] = None
    """
    Custom shape definition (a list of Path elements)
    """

    custom_shape_json: Optional[str] = field(default=None, init=False)

    def before_update(self):
        super().before_update()
        if self.colors is not None:
             self.colors_json = json.dumps(self.colors)
        if self.custom_shape is not None:
             self.custom_shape_json = json.dumps(
                self.custom_shape, 
                default=lambda o: o.__dict__ if hasattr(o, "__dict__") else str(o)
            )

    def _get_control_name(self):
        return "Confetti"

    async def play(self):
        await self._invoke_method("play")

    async def stop(self):
        await self._invoke_method("stop")
