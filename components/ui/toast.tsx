"use client"

import React, { useState, useEffect } from "react"
import { X, Star, Github } from "lucide-react"
import { Button } from "./button"

interface ToastProps {
  message: string
  isVisible: boolean
  onClose: () => void
  duration?: number
  action?: {
    label: string
    onClick: () => void
  }
}

export function Toast({ 
  message, 
  isVisible, 
  onClose, 
  duration = 5000,
  action 
}: ToastProps) {
  useEffect(() => {
    if (isVisible) {
      const timer = setTimeout(() => {
        onClose()
      }, duration)

      return () => clearTimeout(timer)
    }
  }, [isVisible, duration, onClose])

  if (!isVisible) return null

  return (
    <div className="fixed top-4 right-4 z-50 animate-in slide-in-from-top-2 fade-in-0">
      <div className="bg-card border rounded-lg shadow-lg p-4 max-w-sm">
        <div className="flex items-start gap-3">
          <div className="flex-shrink-0">
            <Star className="h-5 w-5 text-yellow-500" />
          </div>
          <div className="flex-1">
            <p className="text-sm font-medium text-foreground">
              {message}
            </p>
            {action && (
              <div className="mt-3">
                <Button
                  size="sm"
                  onClick={action.onClick}
                  className="bg-gradient-to-r from-emerald-500 to-cyan-500 hover:from-emerald-600 hover:to-cyan-600 text-white"
                >
                  <Github className="h-4 w-4 mr-2" />
                  {action.label}
                </Button>
              </div>
            )}
          </div>
          <button
            onClick={onClose}
            className="flex-shrink-0 text-muted-foreground hover:text-foreground transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  )
}

interface ToastContextType {
  showToast: (message: string, action?: { label: string; onClick: () => void }) => void
}

export const ToastContext = React.createContext<ToastContextType | null>(null)

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toast, setToast] = useState<{
    message: string
    isVisible: boolean
    action?: { label: string; onClick: () => void }
  }>({
    message: "",
    isVisible: false
  })

  const showToast = (message: string, action?: { label: string; onClick: () => void }) => {
    setToast({
      message,
      isVisible: true,
      action
    })
  }

  const hideToast = () => {
    setToast(prev => ({ ...prev, isVisible: false }))
  }

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <Toast
        message={toast.message}
        isVisible={toast.isVisible}
        onClose={hideToast}
        action={toast.action}
      />
    </ToastContext.Provider>
  )
}

export function useToast() {
  const context = React.useContext(ToastContext)
  if (!context) {
    throw new Error("useToast must be used within a ToastProvider")
  }
  return context
}
