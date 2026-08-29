--! Copyright (c) 2025-2026 amonamona
--! CC BY-NC-SA 4.0 https://creativecommons.org/licenses/by-nc-sa/4.0/
--! LightBoard Miniboard Renderer

---@class MiniboardRenderOptions
---@field chatIndex number
---@field color string Accent color selected by the module theme.
---@field darkness 'light'|'dark'

---Renders a Miniboard node into HTML.
---@param triggerId string
---@param data MiniboardRenderData
---@param options MiniboardRenderOptions
---@return string
local function render(triggerId, data, options)
  local posts = data.posts
  local chatIndex = options.chatIndex

  local post_es = {}
  if #posts > 0 then
    for pi, post in ipairs(posts) do
      local comment_es = {}
      for ci, comment in ipairs(post.comments) do
        local comment_e = h.div['lb-mini-comment'] {
          h.div['lb-mini-meta'] {
            h.span['lb-mini-author'] {
              comment.author,
            },
            h.span['lb-mini-time'] {
              (comment.time or '')
            },
            h.button['lb-mini-icon-btn lb-mini-delete-comment'] {
              risu_btn = 'lb-mini-delete/' .. chatIndex .. '_' .. pi .. '_' .. ci,
              title = '댓글 삭제',
              type = 'button',
              h.lb_trash_icon { closed = true },
            },
          },
          h.p['lb-mini-comment-content'] {
            comment.content
          }
        }

        table.insert(comment_es, comment_e)
      end

      table.insert(post_es, h.details['lb-mini-post'] {
        name = 'lb-mini-post',
        h.summary['lb-mini-post-summary'] {
          h.div['lb-mini-post-title-container'] {
            h.span['lb-mini-post-title-text'] {
              post.title,
            },
            h.div['lb-mini-meta'] {
              h.span['lb-mini-author'] {
                post.author,
              },
              h.span['lb-mini-time'] {
                post.time,
              },
              h.span {
                '▲ ' .. post.upvotes,
              },
              h.span {
                '▼ ' .. post.downvotes,
              },
            },
          },
        },
        h.div['lb-mini-post-content'] {
          h.p {
            post.content,
          },
          h.hr['lb-mini-hr'] { void = true },
          h.div['lb-mini-rowgap lb-mini-comments'] {
            h.div['lb-mini-comments-header'] {
              h.span['lb-mini-comments-heading'] '댓글',
              h.div['lb-mini-comments-actions'] {
                h.button['lb-mini-btn'] {
                  risu_btn = 'lb-mini-delete/' .. chatIndex .. '_' .. pi,
                  title = '게시글 삭제',
                  type = 'button',
                  h.lb_trash_icon { closed = true },
                  '삭제'
                },
                h.button['lb-mini-btn'] {
                  risu_btn = 'lb-interaction__lb-mini__AddComment/Title:' .. post.title,
                  type = 'button',
                  h.lb_comment_icon { closed = true },
                  '댓글 달기'
                },
              },
            },
            comment_es
          },
        },
      })
    end
  else
    post_es = h.div['lb-no-comments'] {
      style = 'padding: 20px; text-align: center; color: #888;',
      '표시할 게시글 없음',
    }
  end

  local id = 'lb-mini-' .. math.random()

  local boardTitle = data.attributes.name or '미니보드'
  local html = h.div['lb-module-opener-root'] {
    data_id = 'lb-mini',
    h.button['lb-module-opener'] {
      popovertarget = id,
      type = 'button',
      '미니보드',
    },
    h.dialog['lb-dialog lb-mini-dialog'] {
      id = id,
      popover = '',
      h.div['lb-mini-header'] {
        h.b {
          boardTitle
        },
        h.button['lb-mini-btn'] {
          risu_btn = 'lb-interaction__lb-mini__ChangeBoard',
          type = 'button',
          '게시판 둘러보기'
        },
        h.button['lb-mini-btn'] {
          risu_btn = 'lb-interaction__lb-mini__AddPost',
          style = 'margin-left:auto',
          type = 'button',
          h.lb_comment_icon { closed = true },
          '게시글 쓰기'
        },
        h.button['lb-reroll'] {
          risu_btn = 'lb-reroll__lb-mini',
          type = 'button',
          h.lb_reroll_icon { closed = true }
        },
      },
      h.div['lb-mini-wrap'] {
        h.div['lb-mini-container lb-mini-rowgap'] {
          post_es,
        },
      },
      h.button['lb-mini-close'] {
        popovertarget = id,
        type = 'button',
        '닫기',
      }
    },
  }

  return tostring(html)
end

return render
