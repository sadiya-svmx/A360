import getAllEntityDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDefinitions';
import getFieldDefinitions
    from '@salesforce/apex/COMM_MetadataLightningService.getFieldDefinitions';
import getFieldDefinitionsList
    from '@salesforce/apex/COMM_MetadataLightningService.getFieldDefinitionsList';
import getAllEntityDetails
    from '@salesforce/apex/COMM_MetadataLightningService.getAllEntityDetails';

import { verifyApiResponse, parseErrorMessage } from 'c/utils';

/**
 * Returns a collection of entity definitions.
 */
const getEntityDefinitions = () => {
    return getAllEntityDefinitions()
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
};

/**
 * Returns a collection of entity details.
 */
const getEntityDetails = () => {
    return getAllEntityDetails()
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
};

/**
 * Returns a collection of field definitions for a single entity.
 * 
 * @param {string} entityApiName - a string value representing the entity API name
 */
const getFieldDefinitionsForEntity = (entityApiName) => {

    const entityDefinition = {
        apiName: entityApiName
    };

    return getFieldDefinitions({ requestJson: JSON.stringify(entityDefinition) })
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
}

/**
 * Returns a collection of field definitions for multiple entities.
 * 
 * @param {string[]} entityApiNames: an array of entity API names to retrieve field definitions
 */
const getFieldDefinitionsForEntities = (entityApiNames) => {

    const entityDefinitions = entityApiNames.map( entityName => {return { apiName: entityName }} );

    return getFieldDefinitionsList({ requestJson: JSON.stringify(entityDefinitions) })
        .then(result => {
            if (verifyApiResponse(result)) {
                return result;
            }

            throw new Error(result.message);
        })
        .catch(error => {
            throw new Error(parseErrorMessage(error));
        });
}

export {
    getEntityDefinitions,
    getFieldDefinitionsForEntity,
    getFieldDefinitionsForEntities,
    getEntityDetails
};