import { LightningElement, api } from 'lwc';
import { default as images, empty } from "./images/index";
import {
    normalizeString,
} from 'c/utils';

export { images };
export default class IllustrationImage extends LightningElement {

    _imageName;

    @api
    get imageName () {
        return this._imageName;
    }

    set imageName (value) {
        this._imageName = normalizeString(value, {
            fallbackValue: 'empty',
            validValues: Object.keys(images),
        });
    }

    render () {
        const { imageName } = this;

        if (images[imageName]) {
            return images[imageName];
        }

        return empty;
    }
}