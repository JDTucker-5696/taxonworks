import getBiologicalId from './getBiologicalId';
import getCitation from './getCitation';
import getRoles from './getRoles';
import getType from './getType';
import getTypeMaterial from './getTypeMaterial';
import getProtonymId from './getProtonymId';
import getSettings from './getSettings';

import getCollectionObject from './getCollectionObject';
import getCollectionObjectBufferedDeterminations from './getCollectionObjectBufferedDeterminations';
import getCollectionObjectBufferedEvent from './getCollectionObjectBufferedEvent';
import getCollectionObjectBufferedLabels from './getCollectionObjectBufferedLabels';
import getCollectionObjectCollectionEventId from './getCollectionObjectCollectionEventId';
import getCollectionObjectPreparationId from './getCollectionObjectPreparationId';
import getCollectionObjectTotal from './getCollectionObjectTotal';
import getTypeMaterials from './getTypeMaterials';


const GetterNames = {
    GetBiologicalId: 'getBiologicalId',
    GetCitation: 'getCitation',
    GetRoles: 'getRoles',
    GetType: 'getType',
    GetTypeMaterial: 'getTypeMaterial',
    GetProtonymId: 'getProtonymId',
    GetSettings: 'getSettings',
    GetTypeMaterials: 'getTypeMaterials',
    GetCollectionObject: 'getCollectionObject',
    GetCollectionObjectBufferedDeterminations: 'getCollectionObjectBufferedDeterminations',
    GetCollectionObjectBufferedEvent: 'getCollectionObjectBufferedEvent',
    GetCollectionObjectBufferedLabels: 'getCollectionObjectBufferedLabels',
    GetCollectionObjectCollectionEventId: 'getCollectionObjectCollectionEventId',
    GetCollectionObjectPreparationId: 'getCollectionObjectPreparationId',
    GetCollectionObjectTotal: 'getCollectionObjectTotal'
};

const GetterFunctions = {
    [GetterNames.GetBiologicalId]: getBiologicalId,
    [GetterNames.GetCitation]: getCitation,
    [GetterNames.GetRoles]: getRoles,
    [GetterNames.GetType]: getType,
    [GetterNames.GetTypeMaterial]: getTypeMaterial,
    [GetterNames.GetProtonymId]: getProtonymId,
    [GetterNames.GetSettings]: getSettings,
    [GetterNames.GetTypeMaterials]: getTypeMaterials,
    [GetterNames.GetCollectionObject]: getCollectionObject,
    [GetterNames.GetCollectionObjectBufferedDeterminations]: getCollectionObjectBufferedDeterminations,
    [GetterNames.GetCollectionObjectBufferedEvent]: getCollectionObjectBufferedEvent,
    [GetterNames.GetCollectionObjectBufferedLabels]: getCollectionObjectBufferedLabels,
    [GetterNames.GetCollectionObjectCollectionEventId]: getCollectionObjectCollectionEventId,
    [GetterNames.GetCollectionObjectPreparationId]: getCollectionObjectPreparationId,
    [GetterNames.GetCollectionObjectTotal]: getCollectionObjectTotal,
};

export {
    GetterNames,
    GetterFunctions
}