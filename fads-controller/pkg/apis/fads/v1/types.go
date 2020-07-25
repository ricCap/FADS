/*
Copyright 2017 The Kubernetes Authors.

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

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// +genclient
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type FadScaler struct {
	metav1.TypeMeta   `json:",inline"`
	metav1.ObjectMeta `json:"metadata,omitempty"`

	Spec FadScalerSpec `json:"spec"`
}

type FadScalerSpec struct {
	TargetResource TargetResourceSpec `json:"targetResource"`
	Policy         string             `json:"policy"`
	Status         string             `json:"status"`

	Requirements []RequirementSpec `json:"requirements"`
}

type TargetResourceSpec struct {
	Name           string `json:"name"`
	ResourceType   string `json:"resourceType"`
	Namespace      string `json:"namespace"`
	CustomSelector string `json:"customSelector"`
}

type RequirementSpec struct {
	Name          string             `json:"name"`
	TargetMetrics []TargetMetricSpec `json:"targetMetrics"`
}

type TargetMetricSpec struct {
	Name      string `json:"name"`
	Condition string `json:"condition"`
	Value     int    `json:"value"`
	Priority  int    `json:"priority"`
}

// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object

type FadScalerList struct {
	metav1.TypeMeta `json:",inline"`
	metav1.ListMeta `json:"metadata"`

	Items []FadScaler `json:"items"`
}
