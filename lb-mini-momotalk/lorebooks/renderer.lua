---@class MiniboardRenderOptions
---@field chatIndex number
---@field color string
---@field darkness 'light'|'dark'

local function getInitial(name)
  local trimmedName = tostring(name or ''):match('^%s*(.-)%s*$')
  local initial = trimmedName:match('^([%z\1-\127\194-\244][\128-\191]*)')
  if not initial or initial == '' then
    return '?'
  end

  return initial
end

local function renderComment(comment, chatIndex, postIndex, commentIndex)
  local bubbleClass = 'lb-momo-post-bubble'
  local commentContent
  if comment.cons then
    bubbleClass = bubbleClass .. ' lb-momo-con-bubble'
    commentContent = {}
    for _, identifier in ipairs(comment.cons) do
      table.insert(commentContent, h.div['lb-momo-con'] {
        style = 'background-image: url("{{raw::' .. identifier .. '}}");',
      })
    end
  else
    commentContent = h.p {
      comment.content,
    }
  end

  return h.div['lb-momo-comment'] {
    h.div['lb-momo-avatar'] {
      getInitial(comment.author),
    },
    h.div['lb-momo-message'] {
      h.div['lb-momo-message-author'] {
        comment.author,
      },
      h.div['lb-momo-comment-row'] {
        h.div[bubbleClass] {
          commentContent,
        },
        h.div['lb-momo-comment-meta'] {
          h.span {
            comment.time or '',
          },
          h.button['lb-momo-text-action'] {
            risu_btn = 'lb-mini-delete/' .. chatIndex .. '_' .. postIndex .. '_' .. commentIndex,
            title = '댓글 삭제',
            type = 'button',
            '삭제',
          },
        },
      },
    },
  }
end

local function renderPostPanel(post, chatIndex, postIndex)
  local comments = {}
  for commentIndex, comment in ipairs(post.comments) do
    table.insert(comments, renderComment(comment, chatIndex, postIndex, commentIndex))
  end

  if #comments == 0 then
    table.insert(comments, h.div['lb-momo-no-comments'] {
      '아직 댓글이 없습니다',
    })
  end

  return h.section['lb-momo-post-panel lb-momo-post-panel-' .. postIndex] {
    h.div['lb-momo-view-header'] {
      h.div['lb-momo-view-heading'] {
        h.strong {
          post.title,
        },
        h.span {
          post.author .. ' · ' .. (post.time or ''),
        },
      },
    },
    h.div['lb-momo-thread'] {
      h.div['lb-momo-main-post'] {
        h.div['lb-momo-avatar lb-momo-avatar-main'] {
          getInitial(post.author),
        },
        h.div['lb-momo-message'] {
          h.div['lb-momo-message-author'] {
            post.author,
          },
          h.div['lb-momo-post-bubble'] {
            h.p {
              post.content,
            },
          },
          h.div['lb-momo-score-row'] {
            h.span['lb-momo-score'] {
              h.span['lb-momo-score-item'] {
                h.lb_momo_thumbs_up_icon { closed = true },
                post.upvotes,
              },
              h.span['lb-momo-score-item'] {
                h.lb_momo_thumbs_down_icon { closed = true },
                post.downvotes,
              },
            },
            h.button['lb-momo-post-delete'] {
              risu_btn = 'lb-mini-delete/' .. chatIndex .. '_' .. postIndex,
              title = '게시글 삭제',
              type = 'button',
              '삭제',
            },
          },
        },
      },
      h.div['lb-momo-comment-divider'] {
        h.span {
          '댓글 ' .. #post.comments,
        },
      },
      comments,
      h.div['lb-momo-reply'] {
        h.span['lb-momo-reply-heading'] {
          '답장하기',
        },
        h.button['lb-momo-reply-field'] {
          risu_btn = 'lb-interaction__lb-mini__AddComment/Title:' .. post.title,
          type = 'button',
          '답장을 남겨보세요',
        },
      },
    },
  }
end

---@param triggerId string
---@param data MiniboardRenderData
---@param options MiniboardRenderOptions
---@return string
local function render(triggerId, data, options)
  local boardTitle = data.attributes.name or '미니보드'
  local chatIndex = options.chatIndex
  local darknessClass = options.darkness == 'dark' and 'lb-momo-dark' or 'lb-momo-light'
  local instanceId = 'lb-momo-' .. math.random(100000, 999999999)
  local listToggleId = instanceId .. '-list-toggle'
  local postInputs = {}
  local postPanels = {}
  local postRows = {}
  local selectionRules = {}

  for postIndex, post in ipairs(data.posts) do
    local inputId = instanceId .. '-post-' .. postIndex
    local inputAttributes = {
      class = 'lb-momo-post-radio',
      id = inputId,
      name = instanceId .. '-posts',
      type = 'radio',
      void = true,
    }
    if postIndex == 1 then
      inputAttributes.checked = 'checked'
    end

    table.insert(postInputs, h.input(inputAttributes))
    table.insert(postRows, h.label['lb-momo-post-row lb-momo-post-row-' .. postIndex] {
      htmlFor = inputId,
      h.strong['lb-momo-post-author'] {
        post.author,
      },
      h.span['lb-momo-post-time'] {
        post.time or '',
      },
      h.span['lb-momo-post-preview'] {
        post.title,
      },
    })
    table.insert(postPanels, renderPostPanel(post, chatIndex, postIndex))
    table.insert(selectionRules,
      '#' .. inputId .. ':checked ~ .lb-momo-body .lb-momo-post-row-' .. postIndex
      .. '{background:#DAE5E7}'
      .. '#' .. inputId .. ':checked ~ .lb-momo-body .lb-momo-post-panel-' .. postIndex
      .. '{display:grid}')
  end

  if #postRows == 0 then
    table.insert(postRows, h.div['lb-momo-empty-list'] {
      '표시할 게시글이 없습니다',
    })
    table.insert(postPanels, h.div['lb-momo-empty-view'] {
      h.span {
        '게시글을 작성하면 여기에 표시됩니다',
      },
    })
  end

  local html = h.div['lb-module-opener-root lb-momo-root ' .. darknessClass] {
    data_id = 'lb-mini-momotalk',
    h.button['lb-module-opener lb-momo-opener'] {
      popovertarget = instanceId,
      type = 'button',
      '미니보드',
    },
    h.dialog['lb-dialog lb-momo-dialog'] {
      id = instanceId,
      popover = '',
      h.style {
        table.concat(selectionRules),
      },
      h.input['lb-momo-list-toggle'] {
        id = listToggleId,
        type = 'checkbox',
        void = true,
      },
      h.header['lb-momo-topbar'] {
        h.div['lb-momo-brand'] {
          h.strong {
            boardTitle,
          },
        },
        h.button['lb-momo-close'] {
          popovertarget = instanceId,
          title = '닫기',
          type = 'button',
          h.lb_trash_icon { closed = true },
        },
      },
      postInputs,
      h.div['lb-momo-body'] {
        h.nav['lb-momo-sidebar'] {
          h.button['lb-momo-side-button'] {
            risu_btn = 'lb-interaction__lb-mini__ChangeBoard',
            title = '게시판 변경',
            type = 'button',
            h.lb_momo_change_board_icon { closed = true },
          },
          h.label['lb-momo-side-button lb-momo-side-button-active lb-momo-list-toggle-button'] {
            htmlFor = listToggleId,
            title = '현재 게시판',
            h.lb_momo_speech_bubble_icon { closed = true },
          },
        },
        h.label['lb-momo-list-scrim'] {
          htmlFor = listToggleId,
          title = '게시글 목록 닫기',
        },
        h.div['lb-momo-list-pane'] {
          h.div['lb-momo-list-header'] {
            h.strong {
              '게시글 (' .. #data.posts .. ')',
            },
            h.div['lb-momo-list-actions'] {
              h.button['lb-momo-list-button'] {
                risu_btn = 'lb-interaction__lb-mini__AddPost',
                title = '게시글 쓰기',
                type = 'button',
                h.lb_momo_write_icon { closed = true },
              },
              h.button['lb-momo-list-button'] {
                risu_btn = 'lb-reroll__lb-mini',
                title = '게시판 새로 만들기',
                type = 'button',
                h.lb_momo_reroll_icon { closed = true },
              },
            },
          },
          h.div['lb-momo-post-list'] {
            postRows,
          },
        },
        h.main['lb-momo-view-pane'] {
          postPanels,
        },
      },
    },
  }

  return tostring(html)
end

return render
