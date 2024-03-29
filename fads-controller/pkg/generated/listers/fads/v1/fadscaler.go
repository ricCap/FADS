/*
Copyright The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by lister-gen. DO NOT EDIT.

package v1

import (
	"k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/client-go/tools/cache"
	v1 "riccap.example.com/fads/pkg/apis/fads/v1"
)

// FadScalerLister helps list FadScalers.
type FadScalerLister interface {
	// List lists all FadScalers in the indexer.
	List(selector labels.Selector) (ret []*v1.FadScaler, err error)
	// FadScalers returns an object that can list and get FadScalers.
	FadScalers(namespace string) FadScalerNamespaceLister
	FadScalerListerExpansion
}

// fadScalerLister implements the FadScalerLister interface.
type fadScalerLister struct {
	indexer cache.Indexer
}

// NewFadScalerLister returns a new FadScalerLister.
func NewFadScalerLister(indexer cache.Indexer) FadScalerLister {
	return &fadScalerLister{indexer: indexer}
}

// List lists all FadScalers in the indexer.
func (s *fadScalerLister) List(selector labels.Selector) (ret []*v1.FadScaler, err error) {
	err = cache.ListAll(s.indexer, selector, func(m interface{}) {
		ret = append(ret, m.(*v1.FadScaler))
	})
	return ret, err
}

// FadScalers returns an object that can list and get FadScalers.
func (s *fadScalerLister) FadScalers(namespace string) FadScalerNamespaceLister {
	return fadScalerNamespaceLister{indexer: s.indexer, namespace: namespace}
}

// FadScalerNamespaceLister helps list and get FadScalers.
type FadScalerNamespaceLister interface {
	// List lists all FadScalers in the indexer for a given namespace.
	List(selector labels.Selector) (ret []*v1.FadScaler, err error)
	// Get retrieves the FadScaler from the indexer for a given namespace and name.
	Get(name string) (*v1.FadScaler, error)
	FadScalerNamespaceListerExpansion
}

// fadScalerNamespaceLister implements the FadScalerNamespaceLister
// interface.
type fadScalerNamespaceLister struct {
	indexer   cache.Indexer
	namespace string
}

// List lists all FadScalers in the indexer for a given namespace.
func (s fadScalerNamespaceLister) List(selector labels.Selector) (ret []*v1.FadScaler, err error) {
	err = cache.ListAllByNamespace(s.indexer, s.namespace, selector, func(m interface{}) {
		ret = append(ret, m.(*v1.FadScaler))
	})
	return ret, err
}

// Get retrieves the FadScaler from the indexer for a given namespace and name.
func (s fadScalerNamespaceLister) Get(name string) (*v1.FadScaler, error) {
	obj, exists, err := s.indexer.GetByKey(s.namespace + "/" + name)
	if err != nil {
		return nil, err
	}
	if !exists {
		return nil, errors.NewNotFound(v1.Resource("fadscaler"), name)
	}
	return obj.(*v1.FadScaler), nil
}
