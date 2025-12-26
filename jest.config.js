'use strict';

const config = {
  clearMocks: true,
  restoreMocks: true,
  resetMocks: true,

  testEnvironment: 'jsdom',

  testPathIgnorePatterns: ['config/', 'tests/'],
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1'
  },
  transform: {
    '^.+\\.js$': ['@swc/jest']
  },
  setupFilesAfterEnv: [
    './spec/javascript/setupJestDomMatchers.js',
    './spec/javascript/setupExpectEachTestHasAssertions.js'
  ]
};

module.exports = config;
