"""Starter GPIO overlay for the ZC706 evaluation board."""
from pathlib import Path
from pynq import Overlay


class BaseOverlay(Overlay):
    """Expose LEDs, DIP switches and push buttons through AXI GPIO."""

    def __init__(self, bitfile_name=None, **kwargs):
        super().__init__(str(bitfile_name or Path(__file__).with_suffix('.bit')), **kwargs)
