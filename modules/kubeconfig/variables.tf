# Copyright © 2021-2023, SAS Institute Inc., Cary, NC, USA. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

variable "prefix" {
  description = "A prefix used for all Google Cloud resources created by this script"
  type        = string
}

variable "namespace" {
  description = "Namespace that the service account and cluster role binding will placed."
  type        = string
  default     = "kube-system"
}

variable "region" {
  type        = string
  default     = null
}

variable "create_static_kubeconfig" {
  description = "Allows the user to create a provider / service account based kube config file"
  type        = bool
  default     = false
}

variable "path" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "endpoint" {
  type        = string
}

variable "ca_crt" {
  type        = string
}
