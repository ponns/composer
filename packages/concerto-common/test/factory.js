/*
 * IBM Confidential
 * OCO Source Materials
 * IBM Concerto - Blockchain Solution Framework
 * Copyright IBM Corp. 2016
 * The source code for this program is not published or otherwise
 * divested of its trade secrets, irrespective of what has
 * been deposited with the U.S. Copyright Office.
 */

'use strict';

const Factory = require('../lib/factory');
const ModelManager = require('../lib/modelmanager');
const uuid = require('uuid');

const should = require('chai').should();
const sinon = require('sinon');

describe('Factory', () => {

    let factory;
    let modelManager;
    let sandbox;

    beforeEach(() => {
        modelManager = new ModelManager();
        modelManager.addModelFile(`
        namespace org.acme.test
        asset MyAsset identified by assetId {
            o String assetId
            o String newValue
        }
        transaction MyTransaction identified by transactionId {
            o String transactionId
            o String newValue
        }`);
        factory = new Factory(modelManager);
        sandbox = sinon.sandbox.create();
        sandbox.stub(uuid, 'v4').returns('5604bdfe-7b96-45d0-9883-9c05c18fe638');
    });

    afterEach(() => {
        sandbox.restore();
    });

    describe('#newInstance', () => {

        it('should create a new instance with a specified ID', () => {
            let resource = factory.newInstance('org.acme.test', 'MyAsset', 'MY_ID_1');
            resource.assetId.should.equal('MY_ID_1');
            should.equal(resource.newValue, undefined);
            should.not.equal(resource.validate, undefined);
        });

        it('should create a new non-validating instance with a specified ID', () => {
            let resource = factory.newInstance('org.acme.test', 'MyAsset', 'MY_ID_1', { disableValidation: true });
            resource.assetId.should.equal('MY_ID_1');
            should.equal(resource.newValue, undefined);
            should.equal(resource.validate, undefined);
        });

        it('should create a new instance with a specified ID and generated data', () => {
            let resource = factory.newInstance('org.acme.test', 'MyAsset', 'MY_ID_1', { generate: true });
            resource.assetId.should.equal('MY_ID_1');
            resource.newValue.should.be.a('string');
            should.not.equal(resource.validate, undefined);
        });

    });

    describe('#newTransaction', () => {

        it('should throw if ns not specified', () => {
            (() => {
                factory.newTransaction(null, 'MyTransaction');
            }).should.throw(/ns not specified/);
        });

        it('should throw if type not specified', () => {
            (() => {
                factory.newTransaction('org.acme.test', null);
            }).should.throw(/type not specified/);
        });

        it('should throw if a non transaction type was specified', () => {
            (() => {
                factory.newTransaction('org.acme.test', 'MyAsset');
            }).should.throw(/not a transaction/);
        });

        it('should create a new instance with a generated ID', () => {
            let resource = factory.newTransaction('org.acme.test', 'MyTransaction');
            resource.transactionId.should.equal('5604bdfe-7b96-45d0-9883-9c05c18fe638');
            should.equal(resource.newValue, undefined);
            resource.timestamp.should.be.an.instanceOf(Date);
        });

        it('should create a new instance with a specified ID', () => {
            let resource = factory.newTransaction('org.acme.test', 'MyTransaction', 'MY_ID_1');
            resource.transactionId.should.equal('MY_ID_1');
            should.equal(resource.newValue, undefined);
            resource.timestamp.should.be.an.instanceOf(Date);
        });

        it('should pass options onto newInstance', () => {
            let spy = sandbox.spy(factory, 'newInstance');
            factory.newTransaction('org.acme.test', 'MyTransaction', null, { hello: 'world' });
            sinon.assert.calledOnce(spy);
            sinon.assert.calledWith(spy, 'org.acme.test', 'MyTransaction', '5604bdfe-7b96-45d0-9883-9c05c18fe638', { hello: 'world' });
        });

    });

    describe('#toJSON', () => {

        it('should return an empty object', () => {
            let mockModelManager = sinon.createStubInstance(ModelManager);
            let factory = new Factory(mockModelManager);
            factory.toJSON().should.deep.equal({});
        });

    });

});
