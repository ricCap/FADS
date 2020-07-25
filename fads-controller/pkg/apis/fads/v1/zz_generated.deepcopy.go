// +build !ignore_autogenerated

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

// Code generated by deepcopy-gen. DO NOT EDIT.

package v1

import (
	runtime "k8s.io/apimachinery/pkg/runtime"
)

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *FadScaler) DeepCopyInto(out *FadScaler) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ObjectMeta.DeepCopyInto(&out.ObjectMeta)
	in.Spec.DeepCopyInto(&out.Spec)
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new FadScaler.
func (in *FadScaler) DeepCopy() *FadScaler {
	if in == nil {
		return nil
	}
	out := new(FadScaler)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *FadScaler) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *FadScalerList) DeepCopyInto(out *FadScalerList) {
	*out = *in
	out.TypeMeta = in.TypeMeta
	in.ListMeta.DeepCopyInto(&out.ListMeta)
	if in.Items != nil {
		in, out := &in.Items, &out.Items
		*out = make([]FadScaler, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new FadScalerList.
func (in *FadScalerList) DeepCopy() *FadScalerList {
	if in == nil {
		return nil
	}
	out := new(FadScalerList)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyObject is an autogenerated deepcopy function, copying the receiver, creating a new runtime.Object.
func (in *FadScalerList) DeepCopyObject() runtime.Object {
	if c := in.DeepCopy(); c != nil {
		return c
	}
	return nil
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *FadScalerSpec) DeepCopyInto(out *FadScalerSpec) {
	*out = *in
	out.TargetResource = in.TargetResource
	if in.Requirements != nil {
		in, out := &in.Requirements, &out.Requirements
		*out = make([]RequirementSpec, len(*in))
		for i := range *in {
			(*in)[i].DeepCopyInto(&(*out)[i])
		}
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new FadScalerSpec.
func (in *FadScalerSpec) DeepCopy() *FadScalerSpec {
	if in == nil {
		return nil
	}
	out := new(FadScalerSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *RequirementSpec) DeepCopyInto(out *RequirementSpec) {
	*out = *in
	if in.TargetMetrics != nil {
		in, out := &in.TargetMetrics, &out.TargetMetrics
		*out = make([]TargetMetricSpec, len(*in))
		copy(*out, *in)
	}
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new RequirementSpec.
func (in *RequirementSpec) DeepCopy() *RequirementSpec {
	if in == nil {
		return nil
	}
	out := new(RequirementSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *TargetMetricSpec) DeepCopyInto(out *TargetMetricSpec) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new TargetMetricSpec.
func (in *TargetMetricSpec) DeepCopy() *TargetMetricSpec {
	if in == nil {
		return nil
	}
	out := new(TargetMetricSpec)
	in.DeepCopyInto(out)
	return out
}

// DeepCopyInto is an autogenerated deepcopy function, copying the receiver, writing into out. in must be non-nil.
func (in *TargetResourceSpec) DeepCopyInto(out *TargetResourceSpec) {
	*out = *in
	return
}

// DeepCopy is an autogenerated deepcopy function, copying the receiver, creating a new TargetResourceSpec.
func (in *TargetResourceSpec) DeepCopy() *TargetResourceSpec {
	if in == nil {
		return nil
	}
	out := new(TargetResourceSpec)
	in.DeepCopyInto(out)
	return out
}