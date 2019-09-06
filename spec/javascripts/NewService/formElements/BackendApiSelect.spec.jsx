// @flow

import React from 'react'
import {act} from 'react-dom/test-utils'
import Enzyme, {shallow} from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'

import {BackendApiSelect} from 'NewService/components/FormElements'
import { BASE_PATH } from 'NewService'

Enzyme.configure({adapter: new Adapter()})

const props = {
  backendApis: []
}

it('should render select element', () => {
  const wrapper = shallow(<BackendApiSelect {...props} />)
  expect(wrapper.find('select[name="service[backend_api]"]').exists()).toEqual(true)
})