package coconut.feathersui.internal;

import feathers.core.ValidatingSprite;
import coconut.diffing.internal.*;
import coconut.diffing.*;

enum Inlay {
  Empty;
  Singular(cell:RCell<ValidatingSprite>);
  Plural(p:RCell<ValidatingSprite>);
}