import { generateModelController } from 'c/modelController';

import UtilsModelController from './utils';
import SchemaModelController from './schema';
import UiModelController from './ui';
import ResultsModelController from './results';
import SearchModelController from './search';
import StaticConfigModelController from './staticConfig';
import ContextSearchModelController from './contextSearch';
import SelectionModelController from './selection';
import WiresModelController from './wires';
import AdvancedSearchModelController from './advancedSearch';
import DebugModelController from './debug';

export function generateLookupModelController (compInstance, compPropertyMapping = {}) {
    return generateModelController(
        compInstance,
        compPropertyMapping,
        {
            'utils': new UtilsModelController(),
            'staticConfig': new StaticConfigModelController(),
            'ui': new UiModelController(),
            'schema': new SchemaModelController(),
            'contextSearch': new ContextSearchModelController(),
            'search': new SearchModelController(),
            'results': new ResultsModelController(),
            'selection': new SelectionModelController(),
            'wires': new WiresModelController(),
            'advancedSearch': new AdvancedSearchModelController(),
            'debug': new DebugModelController()
        }
    );
}